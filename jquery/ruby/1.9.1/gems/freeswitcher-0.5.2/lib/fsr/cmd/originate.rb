require "fsr/app"
module FSR
  module Cmd
    class Originate < Command
      attr_accessor :target, :endpoint
      attr_reader :fs_socket, :target_options

      def initialize(fs_socket = nil, args = {})
        # Using an argument hash may not be the the best way to go here, but as long as we're doing
        # so we'll type check it
        raise(ArgumentError, "args (Passed: <<<#{args}>>>) must be a hash") unless args.kind_of?(Hash)

        # These are options that will precede the target address
        if args[:target_options]
          raise(ArgumentError, "args[:target_options] (Passed: <<<#{args[:target_options]}>>>) must be a hash") unless args[:target_options].kind_of?(Hash)
        else
          args[:target_options] = {}
        end
        @target_options = default_options(args[:target_options]) do |o|
          o[:origination_caller_id_number] = args[:caller_id_number] if args[:caller_id_number]
          o[:origination_caller_id_name] = args[:caller_id_name] if args[:caller_id_name]
          if o[:timeout]
            o[:originate_timeout] = o.delete(:timeout)
          elsif args[:timeout]
            o[:originate_timeout] = args[:timeout]
          end
          o
        end
        raise(ArgumentError, "Origination timeout (#{@target_options[:originate_timeout]}) must be a positive integer") unless @target_options[:originate_timeout].to_i > 0
        
        @fs_socket = fs_socket # This socket must support say and <<
        @target = args[:target] # The target address to call
        raise(ArgumentError, "Cannot originate without a :target set") unless @target.to_s.size > 0
        # The origination endpoint (can be an extension (use a string) or application)
        @endpoint = args[:endpoint] || args[:application]
        raise(ArgumentError, "Cannot originate without an :endpoint set") unless @endpoint.to_s.size > 0

      end

      # Send the command to the event socket, using bgapi by default.
      def run(api_method = :bgapi)
        orig_command = "%s %s" % [api_method, raw]
        Log.debug "saying #{orig_command}"
        @fs_socket.say(orig_command)
      end

      # This method builds the API command to send to the freeswitch event socket
      def raw
        target_opts = @target_options.keys.sort { |a,b| a.to_s <=> b.to_s }.map { |k| "%s=%s" % [k, @target_options[k]] }.join(",")
        if @endpoint.kind_of?(String)
          orig_command = "originate {#{target_opts}}#{@target} #{@endpoint}"
        elsif @endpoint.kind_of?(FSR::App::Application)
          orig_command = "originate {#{target_opts}}#{@target} '&#{@endpoint.raw}'"
        else
          raise "Invalid endpoint"
        end
      end

    end

    register(:originate, Originate)
  end
end
