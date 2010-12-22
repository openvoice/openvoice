require "fsr/app"
module FSR
  module Cmd
    class Sofia < Command
      def initialize(fs_socket = nil)
        @fs_socket = fs_socket # FSR::CommandSocket obj
      end

      # sofia status
      def status(args = {})
        require "fsr/cmd/sofia/status" # Require sofia/status
        Status.new(@fs_socket, args)
      end

      # sofia profile
      def profile(args = nil)
        require "fsr/cmd/sofia/profile" # Require sofia/profile
        if args == nil
          Profile.new(@fs_socket, :command_string => "")
        else
          Profile.new(@fs_socket, args)
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
        orig_command = "sofia"
      end
    end

  register(:sofia, Sofia) 
  end
end
