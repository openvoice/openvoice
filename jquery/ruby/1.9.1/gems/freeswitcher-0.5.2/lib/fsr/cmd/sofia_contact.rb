# A lot of methods are missing here. The only one implemented is max_sessions
# The max_sessions getter currently returns the raw result but could instead return an Integer

require "fsr/app"
module FSR
  module Cmd
    class SofiaContact < Command
      attr_reader :contact

      def initialize(fs_socket = nil, contact = {})
        @fs_socket = fs_socket # FSR::CommandSocket obj
        @contact = contact[:contact]
        #puts @contact
      end

      # Send the command to the event socket, using api by default.
      def run(api_method = :api)
        orig_command = "%s %s" % [api_method, raw]
        Log.debug "saying #{orig_command}"
        resp = @fs_socket.say(orig_command)
        resp["body"].match(%r{^error/}) ? nil : resp["body"]
      end
    
      # This method builds the API command to send to the freeswitch event socket
      def raw
        orig_command = "sofia_contact #{@contact}"
      end
    end

  register(:sofia_contact, SofiaContact)
  end
end
