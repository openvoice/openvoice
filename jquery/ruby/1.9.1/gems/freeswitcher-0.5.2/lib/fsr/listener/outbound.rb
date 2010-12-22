require 'rubygems'
require 'eventmachine'
require 'fsr/listener'
require 'fsr/listener/header_and_content_response'

module FSR
  load_all_applications
  module Listener
    class Outbound < EventMachine::Protocols::HeaderAndContentProtocol
      attr_reader :session

      # Include FSR::App to get all the applications defined as methods
      include FSR::App

      # Redefine the FSR::App methods to wrap sendmsg around them
      SENDMSG_METHOD_DEFINITION = [
                                   "def %s(*args, &block)",
                                   "  sendmsg super",
                                   " @queue.unshift(block_given? ? block : lambda {})",
                                   "end"
                                  ].join("\n")

      APPLICATIONS.each do |app, obj| 
        if obj.const_defined?("SENDMSG_METHOD")
          module_eval(obj::SENDMSG_METHOD)
        else
          module_eval(SENDMSG_METHOD_DEFINITION % app.to_s)
        end
      end

      # session_initiated is called when a @session is first created.
      # Overwrite this in your worker class with the call/channel
      # handling logic you desire
      def session_initiated
        FSR::Log.warn "#{self.class.name}#session_initiated not overwritten"
        FSR::Log.debug session_data.inspect
      end

      # receive_reply is called when a response is received.
      # Overwrite this in your worker class with the call/channel
      # handling logic you desire, taking @step into account for
      # state management between commands
      # @param reply This HeaderAndContent instance will have the channel variables
      #              in #content, if the session has been updated
      def receive_reply(reply)
        FSR::Log.debug reply.inspect
      end

      # sendmsg sends data to the EM app socket via #send_data, or
      # returns the string it would send if #send_data is not defined.
      # It expects an object which responds to either #sendmsg or #to_s, 
      # which should return a EM Outbound Event Socket formatted instruction
      
      def sendmsg(message)
        text = message.respond_to?(:sendmsg) ? message.sendmsg : message.to_s
        message = "sendmsg\n%s\n" % text
        self.respond_to?(:send_data) ? send_data(message) : message
      end

      # API
      def api(command, &block)
        send_data("api #{command}\r\n\r\n")
        @queue.unshift block if block_given?
      end

      # Update_session

      def update_session(&block)
        send_data("api uuid_dump #{@session.headers[:unique_id]}\n\n")
        @queue.unshift block if block_given?
      end

      # Scheduel Hangup

      def sched_hangup(secs, &block)
        send_data("api sched_hangup +#{secs} #{@session.headers[:unique_id]} alotted_timeout\n\n")
        @queue.unshift block if block_given?
      end

      def next_step
        @step += 1
        receive_reply(@session)
      end

      protected
      def post_init
        @read_var = nil
        @session = nil # holds the session object
        @queue = [] # Keep track of queue for state machine
        send_data("connect\n\n")
        FSR::Log.debug "Accepting connections."
      end

      # receive_request is called each time data is received by the event machine
      #  it will manipulate the received data into either a new session or a reply,
      #  to be picked up by #session_initiated or #receive_reply.
      #  If your listener is listening for events, this will also renew your @session
      #  each time you receive a CHANNEL_DATA event.
      #
      # @param header The header of the request, as passed by HeaderAndContentProtocol
      # @param content The content of the request, as passed by HeaderAndContentProtocol
      #
      # @return [HeaderAndContentResponse] An EventMachine HeaderAndContentResponse
      def receive_request(header, content)
        hash_header = headers_2_hash(header)
        if content.to_s.match(/:/)
          hash_content = headers_2_hash(content)
        else
          hash_content = content
        end
        session_header_and_content = HeaderAndContentResponse.new({:headers => hash_header, :content => hash_content})
        # If we're a new session, call session initiate
        if session.nil?
          establish_new_session(session_header_and_content)
        elsif @uuid_var  and session_header_and_content.headers[:content_type] == "api/response"
          FSR::Log.info("@uuid_var is set => #{session_header_and_content.inspect} : #{content}")
          r, @uuid_var = session_header_and_content.content.strip, nil
          @queue.pop.call(r) if @queue.size > 0
        elsif @api_request and session_header_and_content.headers[:content_type] == "api/response"
          @queue.pop.call if @queue.size > 0
        elsif session_header_and_content.content.class == Hash
          if session_header_and_content.content[:event_name] # If content includes an event_name, it must be a response from an api command
            check_for_updated_session(session_header_and_content, hash_content, hash_header)
          end
        else
          update_state_machine(session_header_and_content)
        end
      end

      protected
      def queue_pop
        if @queue.size > 0
          if @read_var and session.headers[@read_var.to_sym]
            r, @read_var = @read_var.to_sym, nil
            @queue.pop.call(session.headers[r])
          else
            @queue.pop.call
          end
        end
      end

      private
      # establish_new_session is called once during a new session.
      # This establishes and sets up the variables used to hold state.  
      # Called from #receive_request
      #
      # @param header_and_content_hash HeaderAndContentProtocol object representing the session
      #
      # @return header_and_content_hash HeaderAndContentProtocol object representing the session
      def establish_new_session(header_and_content_hash)
        @session = header_and_content_hash
        @step = 0
        @state = [:uninitiated]
        session_initiated 
        @state << :initiated
        header_and_content_hash
      end
      
      # check_for_updated_session is called from #receive_request if a session has already been established
      # This will overwrite @session with the new variables representing state.  
      #
      # @param header_and_content_hash HeaderAndContentProtocol object
      # @param hash_content hash of content from standard Header and Content Protocol
      # @param hash_header hash of headers from standard Header and Content Protocol
      def check_for_updated_session(header_and_content_hash, hash_content, hash_header)
        if header_and_content_hash.content[:event_name].to_s.match(/CHANNEL_DATA/i) # Anytime we see CHANNEL_DATA event, we want to update our @session
          header_and_content_hash = HeaderAndContentResponse.new({:headers => hash_header.merge(hash_content.strip_value_newlines), :content => {}})
          @session = header_and_content_hash
          update_state_machine(header_and_content_hash.headers)
        end
      end

      # update_state_machine when called will increment @step, 
      # call the next block from @queue and dispatch the callback method
      # #receive_reply
      # @param response_header Response sent to #recieve_reply callback method
      def update_state_machine(response_header)
        @step += 1 if @state.include?(:initiated)
        queue_pop
        receive_reply(response_header)
      end

    end
  end
end

class Hash
  def strip_value_newlines
    Hash[*(self.map { |k,v| v.respond_to?(:to_s) ? [k, v.to_s.strip] : [k, v] }.flatten)]
  end
end
