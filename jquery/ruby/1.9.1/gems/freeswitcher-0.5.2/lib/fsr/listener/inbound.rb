require 'rubygems'
require 'eventmachine'
require 'fsr/listener'
require 'fsr/listener/header_and_content_response.rb'

module FSR
  module Listener
    class Inbound < EventMachine::Protocols::HeaderAndContentProtocol
      attr_reader :auth, :hooks, :server, :port, :subscribed_events, :subscribed_sub_events

      HOOKS = {}

      def initialize(args = {})
        super
        @auth = args[:auth] || "ClueCon"
        @host = args[:host]
        @port = args[:port]
        @subscribed_events = []
        @subscribed_sub_events = []
        @hooks = {}
        @output_format = args[:output_format] || "json"
      end

      # post_init is called upon each "new" socket connection.
      #
      # If Freeswitcher hasn't started listening for inbound socket connections
      # yet, EventMachine will silently do nothing. A periodic timer is added
      # to check wether the connection has been initiated yet, otherwise tries
      # again in five seconds.
      def post_init
        if error?
          reconnect_until_succeeding
        else
          authorize_and_register_for_events
        end
      end

      def reconnect_until_succeeding
        timer = EM::PeriodicTimer.new(5) {
          if error?
            FSR::Log.info "Couldn't establish connection. Trying again..."
           reconnect @host, @port
          else
            timer.cancel
            authorize_and_register_for_events
          end
        }
      end

      def authorize_and_register_for_events
        FSR::Log.info "Connection established. Authorizing..."
        say("auth #{@auth}")
        before_session
      end

      def before_session 
      end

      private :before_session

      # receive_request is the callback method when data is recieved from the socket
      #
      # param header headers from standard Header and Content protocol
      # param content content from standard Header and Content protocol
      def receive_request(header, content)
        hash_header = headers_2_hash(header)
        case hash_header[:content_type]
        when "command/reply"
          return handle_reply(header, content)
        when "text/event-plain"
          hash_content = headers_2_hash(content)
        when "text/event-json"
          require "json"
          hash_content = JSON.parse(content)
        when "auth/request"
          return
        else
          FSR::Log.warn "Unhandled request (#{header}, #{content})"
          return
        end
        hash_content ||= {}
        event = HeaderAndContentResponse.new({:headers => hash_header, :content => hash_content})
        event_name = event.content[:event_name].to_s.strip
        unless event_name.empty?
          # Special case for ALL in instance level @hooks
          if hook = @hooks[:ALL]
            hook.call(event)
          end
          # Special case for ALL in class level HOOKS
          if hook = HOOKS[:ALL]
            case hook.arity
            when 1
              hook.call(event)
            when 2
              hook.call(self, event)
            end
          end
          # General event matching, only on Event-Name, for instance level @hooks
          if hook = @hooks[event_name.to_sym]
            hook.call(event)
          end
          # General event matching, only on Event-Name, for class-level HOOKS
          if hook = HOOKS[event_name.to_sym]
            case hook.arity
            when 1
              hook.call(event)
            when 2
              hook.call(self, event)
            end
          end
        end
        on_event(event)
      end

      # say encapsulates #send_data for the user
      #
      # param line Line of text to send to the socket
      def say(line)
        send_data("#{line}\r\n\r\n")
      end

      def subscribe_to_event(event, sub_events = [])
        sub_events = [sub_events] unless sub_events.kind_of?(Array)
        @subscribed_events << event
        @subscribed_sub_events += sub_events
        if custom = @subscribed_events.delete(:CUSTOM)
          say "event #{@output_format} #{@subscribed_events.join(" ")} CUSTOM #{@subscribed_sub_events.join(" ")}"
        else
          say "event #{@output_format} #{@subscribed_events.join(" ")}"
        end
      end

      # api encapsulates #say("api blah") for the user
      #
      # param line Line of text to send to the socket proceeding api
      def api(line)
        say("api #{line}")
      end
      
      # on_event is the callback method when an event is triggered
      #
      # param event The triggered event object
      # return event The triggered event object
      def on_event(event)
        event
      end
      
      # handle_reply is the callback method when a command_reply is received
      #
      # param header The header of the data
      # param content The content of the data
      # return [header, content]
      def handle_reply(header, content)
        [header, content]
      end

      # add_event_hook adds an Event to listen for.  When that Event is triggered, it will call the defined block
      #
      # @param event The event to trigger the block on.  Examples, :CHANNEL_CREATE, :CHANNEL_DESTROY, etc
      # @param block The block to execute when the event is triggered
      def self.add_event_hook(event, sub_events = [], &block)
        ObjectSpace.each_object { |e| e.subscribe_to_event(event, sub_events) if e.class.ancestors.include?(FSR::Listener::Inbound) }
        HOOKS[event] = block 
      end

      # del_event_hook removes an Event.
      #
      # @param event The event to remove.  Examples, :CHANNEL_CREATE, :CHANNEL_DESTROY, etc
      def self.del_event_hook(event)
        HOOKS.delete(event)  
      end

      # add_event_hook adds an Event to listen for.  When that Event is triggered, it will call the defined block
      #
      # @param event The event to trigger the block on.  Examples, :CHANNEL_CREATE, :CHANNEL_DESTROY, etc
      # @param block The block to execute when the event is triggered
      def add_event(event, sub_events = [], &block)
        subscribe_to_event(event, sub_events)
        @hooks[event] = block 
      end

      # del_event_hook removes an Event.
      #
      # @param event The event to remove.  Examples, :CHANNEL_CREATE, :CHANNEL_DESTROY, etc
      def del_event(event)
        @hooks.delete(event)  
      end

    end

  end
end
