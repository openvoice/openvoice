require "fsr/app"
module FSR
  module App
    # http://wiki.freeswitch.org/wiki/Misc._Dialplan_Tools_set
    class Set < Application
      def initialize(key, value)
        @key = key
        @value = value
      end

      def arguments
        [@key, @value]
      end

      def sendmsg
        "call-command: execute\nexecute-app-name: %s\nexecute-app-arg: %s\nevent-lock:true\n\n" % [app_name, arguments.join("=")] 
      end
    end

    register(:set, Set)
  end
end
