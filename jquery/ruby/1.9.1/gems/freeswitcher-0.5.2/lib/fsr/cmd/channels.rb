require "fsr/app"
module FSR
  module Cmd
    class Channels < Command

      include Enumerable
      def each(&block)
        @channels ||= run
        if @channels
          @channels.each { |call| yield call }
        end
      end

      def initialize(fs_socket = nil, distinct = true)
        @distinct = distinct
        @fs_socket = fs_socket # FSR::CommandSocket obj
      end

      # Send the command to the event socket, using bgapi by default.
      def run(api_method = :api)
        orig_command = "%s %s" % [api_method, raw]
        Log.debug "saying #{orig_command}"
        resp = @fs_socket.say(orig_command)
        unless resp["body"] == "0 total."
          call_info, count = resp["body"].split("\n\n")
          require "fsr/model/channel"
          begin
            require "fastercsv"
            @channels = FCSV.parse(call_info)
          rescue LoadError
            require "csv"
            @channels = CSV.parse(call_info)
          end
          return @channels[1 .. -1].map { |c| FSR::Model::Channel.new(@channels[0],*c) }
        end
        []
      end

      # This method builds the API command to send to the freeswitch event socket
      def raw
        orig_command = @distinct ? "show distinct_channels" : "show channels"
      end
    end

    register(:channels, Channels)
  end
end
