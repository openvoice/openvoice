require "fsr/app"
module FSR
  module App
    # http://wiki.freeswitch.org/wiki/Misc._Dialplan_Tools_log
    class Log < Application
      attr_reader :level, :text

      def initialize(level = 1, text = "")
        @level = level
        @text = text
      end

      def arguments
        [@level, @text]
      end

      def sendmsg
        "call-command: execute\nexecute-app-name: %s\nexecute-app-arg: %s\nevent-lock:true\n\n" % [app_name, arguments.join(" ")]
      end
    end

    register(:log, Log)
  end
end
