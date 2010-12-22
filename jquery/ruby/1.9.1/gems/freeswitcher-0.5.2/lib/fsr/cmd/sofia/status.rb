require "fsr/app"
module FSR
  module Cmd
    class Sofia 
      class Status < Command
        attr_reader :fs_socket

        def initialize(fs_socket = nil, args = {})
          @fs_socket = fs_socket # FSR::CommandSocket object
          @status  = args[:status] # Status type; profile or gateway
          @name = args[:name] # Name of profile or gateway
          # If status is given, make sure it's profile or gateway
          unless @status.nil?
            raise "status must be profile or gateway" unless @status =~ /profile|gateway/i
          end
          if @status
            raise "must provide a profile or gateway name" unless @name
          end
        end

        # Send the command to the event socket, using api by default.
        def run(api_method = :api)
          orig_command = "%s %s" % [api_method, raw]
          Log.debug "saying #{orig_command}"
          @fs_socket.say(orig_command)
        end

        # This method builds the API command to send to the freeswitch event socket
        def raw
          if @status and @name
            orig_command = "sofia status #{@status} #{@name}"
          else
            orig_command = "sofia status"
          end
        end
      end
    end
  end
end
