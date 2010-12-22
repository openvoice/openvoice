require "fsr/app"
module FSR
  module Cmd
    class Sofia 
      class Profile < Command
        attr_reader :options
        attr_accessor :fs_socket, :command_string, :name, :action

        VALID_ACTIONS = [:start, :stop, :restart, :rescan]
        def initialize(fs_socket = nil, options = nil)
          @fs_socket = fs_socket # FSR::CommandSocket object
          if options.kind_of?(String)
            @command_string = options
          else
            raise "options must be a String or Hash" unless options.kind_of?(Hash)
            @options = options
            @action = @options[:action]
            if @action
              raise "Invalid action, must specify one of #{VALID_ACTIONS.inspect}" unless VALID_ACTIONS.include?(@action)
              @name = @options[:name]
              raise "Invalid profile name" unless @name.to_s.match(/\w/)
            else
              @command_string = @options[:command_string] # If user wants to send a raw "sofia profile"
            end
          end
          @command_string ||= ""
        end

        VALID_ACTIONS.each do |action|
          define_method(action, lambda { |name| @action, @name = action, name;self })
        end

        # Send the command to the event socket, using api by default.
        def run(api_method = :api)
          orig_command = "%s %s" % [api_method, raw]
          Log.debug "saying #{orig_command}"
          @fs_socket.say(orig_command)
        end

        def self.start(profile, socket = FSR::CommandSocket.new)
          new(socket, :name => profile, :action => :start)
        end

        # Restart a sip_profile
        def self.restart(profile, socket = FSR::CommandSocket.new)
          new(socket, :name => profile, :action => :restart)
        end

        # Stop a sip_profile
        def self.stop(profile, socket = FSR::CommandSocket.new)
          new(socket, :name => profile, :action => :stop)
        end

        # Rescan a sip_profile
        def self.rescan(profile, socket = FSR::CommandSocket.new)
          new(socket, :name => profile, :action => :rescan)
        end

        # This method builds the API command to send to the freeswitch event socket
        def raw
          raise "Invalid action, must specify (start|stop|restart|rescan) as an action or pass a command_string" unless @command_string or @action
          if @action
            if @action_options
              "sofia profile %s %s %s" % [@name, @action, @action_options]
            else
              "sofia profile %s %s" % [@name, @action]
            end
          else
            "sofia profile %s" % @command_string
          end.to_s.strip
        end
      end
    end
  end
end
