require "fsr/app"
module FSR
  module Cmd
    class CallCenter < Command
      attr_accessor :cmd
      def initialize(fs_socket = nil, config_type = :agent)
        @fs_socket = fs_socket # FSR::CommandSocket obj
        @config_type = config_type
        @last_repsonse = nil
        @cmd = []
      end

      def list_agent
        ["list"]
      end

      def last_response
        responses.last
      end

      def responses
        @responses ||= []
      end

      def list_tier(queue)
        ["list", queue]
      end

      def list_queue(queue=nil)
        ["list", queue].compact
      end

      def list(*args)
        @listing = true
        @cmd = case @config_type
        when :agent
          list_agent(*args)
        when :tier
          list_tier(*args)
        when :queue
          list_queue(*args)
        else
          raise "no such config_type #{@config_type}"
        end
        self
      end


      def set_agent(agent, field, value)
        value = value.respond_to?(:each_char) ? "'#{value}'" : value
        ["set", field.to_s, "'#{agent}'", value].compact
      end

      def set_tier(agent, queue, field, value)
        ["set", field.to_s, queue, agent, "'#{value}'"].compact
      end

      def set(agent, *args)
        @listing = false
        @cmd = case @config_type
        when :agent
          set_agent(agent, *args)
        when :tier
          set_tier(agent, *args)
        else
          raise "Cannot run set on #{@config_type}"
        end
        self
      end

      def add_tier(agent, queue, level = 1, position = nil)
        ["add", queue, agent, level, position].compact
      end

      def add_agent(agent, callback = nil)
        callback ||= 'callback'
        ["add", "'#{agent}'", callback].compact
      end

      def add(agent, *args)
        @listing = false
        @cmd = case @config_type
        when :agent
          add_agent(agent, *args)
        when :tier
          add_tier(agent, *args)
        else
          raise "Cannot add to #{@config_type}"
        end
        self
      end

      protected :list_agent, :list_tier, :list_queue, :set_agent, :set_tier, :add_tier, :add_agent
      def del(agent, queue = nil)
        @listing = false
        @cmd = ["del", queue, agent].compact        
        self
      end

      def run(api_method = :api)
        orig_command = "%s %s" % [api_method, raw]
        resp = @fs_socket.say(orig_command)
        responses << resp
        if @listing
          if resp["body"].match(/^([^|]*\|[^|]*)+/)
            require "csv"
            csv = CSV.parse(resp["body"], :col_sep => '|', :headers => true)
            case @config_type
            when :tier
              require "fsr/model/tier"
              csv.to_a[1 .. -2].map { |c| FSR::Model::Tier.new(csv.headers, *c) }
            when :queue
              require "fsr/model/queue"
              csv.to_a[1 .. -2].map { |c| FSR::Model::Queue.new(csv.headers, *c) }
            when :agent
              require "fsr/model/agent"
              csv.to_a[1 .. -2].map { |c| FSR::Model::Agent.new(csv.headers, *c) }
            end
          else
            []
          end
        else
          resp["body"].to_s =~ /\+OK$/
        end
      end
=begin
      # Send the command to the event socket, using bgapi by default.
      def run(api_method = :api)
        orig_command = "%s %s" % [api_method, raw]
        Log.debug "saying #{orig_command}"
        resp = @fs_socket.say(orig_command)
        unless resp["body"] == "0 total."
          call_info, count = resp["body"].split("\n\n")
          require "fsr/model/call"
          begin
            require "fastercsv"
            @calls = FCSV.parse(call_info)
          rescue LoadError
            require "csv"
            @calls = CSV.parse(call_info)
          end
          return @calls[1 .. -1].map { |c| FSR::Model::Call.new(@calls[0],*c) }
        end
        []
      end
=end

      # This method builds the API command to send to the freeswitch event socket
      def raw
        ["callcenter_config", @config_type, *@cmd].join(" ")
      end
    end

    register(:call_center, CallCenter)
  end
end
