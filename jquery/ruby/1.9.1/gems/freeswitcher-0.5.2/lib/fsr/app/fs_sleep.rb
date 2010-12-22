
require "fsr/app"
module FSR
  module App
    class FSSleep < Application
      attr_reader :milliseconds

      def initialize(milliseconds)
        # milliseconds to sleep 
        @milliseconds = milliseconds
      end
      def arguments
        [@milliseconds]
      end

      def sendmsg
        "call-command: execute\nexecute-app-name: sleep\nexecute-app-arg: %s\n\n" % [arguments.join(" ")]
      end

    end

    register(:fs_sleep, FSSleep)
  end
end
