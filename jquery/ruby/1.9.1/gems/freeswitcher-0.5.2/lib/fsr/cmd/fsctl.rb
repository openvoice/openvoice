# A lot of methods are missing here. The only one implemented is max_sessions
# The max_sessions getter currently returns the raw result but could instead return an Integer

require "fsr/app"
module FSR
  module Cmd
    class Fsctl < Command
      attr_reader :command

      def initialize(fs_socket = nil)
        @fs_socket = fs_socket # FSR::CommandSocket obj
      end

      # Get max sessions
      def max_sessions
        @command = "max_sessions"
        run
      end

      # Set max sessions
      def max_sessions=(sessions)
        @command = "max_sessions #{sessions}"
        run
      end

      # Send the command to the event socket, using api by default.
      def run(api_method = :api)
        orig_command = "%s %s" % [api_method, raw]
        Log.debug "saying #{orig_command}"
        @fs_socket.say(orig_command)
      end
    
      # This method builds the API command to send to the freeswitch event socket
      def raw
        orig_command = "fsctl #{@command}"
      end
    end

  register(:fsctl, Fsctl)
  end
end
