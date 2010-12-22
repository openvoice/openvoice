require "fsr/app"
module FSR
  module Cmd
    class UuidDump < Command
      attr_reader :uuid

      def initialize(fs_socket = nil, unique_id = nil)
        @fs_socket = fs_socket # FSR::CommandSocket obj
        @uuid = unique_id # Freeswitch Unique ID to dump
      end

      # Send the command to the event socket, using bgapi by default.
      def run(api_method = :api)
        orig_command = "%s %s" % [api_method, raw]
        Log.debug "saying #{orig_command}"
        @fs_socket.say(orig_command)
      end

      # This method builds the API command to send to the freeswitch event socket
      def raw
        orig_command = "uuid_dump #{uuid}"
      end
    end

    register(:uuid_dump, UuidDump)
  end
end
