require "fsr/app"
module FSR
  module App
    class Transfer < Application
      attr_reader :destination_number, :dialplan, :context

      def initialize(destination_number, dialplan = nil, context = nil)
        @destination_number = destination_number
        @dialplan = dialplan
        @context = context
      end

      def arguments
        [@destination_number, @dialplan, @context]
      end

      def sendmsg
        "call-command: execute\nexecute-app-name: %s\nexecute-app-arg: %s\nevent-lock:true\n\n" % [app_name, arguments.join(" ")]
      end
    end

    register(:transfer, Transfer)
  end
end
