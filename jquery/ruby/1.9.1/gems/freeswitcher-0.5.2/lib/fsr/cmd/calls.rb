require "fsr/app"
module FSR
  module Cmd
    class Calls < Command

      include Enumerable
      def each(&block)
        @calls ||= run
        if @calls
          @calls.each { |call| yield call }
        end
      end

      def initialize(fs_socket = nil)
        @fs_socket = fs_socket # FSR::CommandSocket obj
      end

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

      # This method builds the API command to send to the freeswitch event socket
      def raw
        orig_command = "show calls"
      end
    end

    register(:calls, Calls)
  end
end
