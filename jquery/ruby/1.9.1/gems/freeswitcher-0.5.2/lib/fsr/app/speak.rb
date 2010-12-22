
require "fsr/app"
module FSR
  module App
    class Speak < Application
      attr_reader :message

      def initialize(message, opts = {})
        # wav file you wish to play, full path 
        @message = message
        @voice = opts[:voice] || "slt"
        @engine = opts[:engine] || "flite"
      end

      def arguments
        [@engine, @voice, @message]
      end

      def sendmsg
        "call-command: execute\nexecute-app-name: %s\nexecute-app-arg: %s\nevent-lock:true\n\n" % [app_name, arguments.join("|")] 
      end
    end

    register(:speak, Speak)
  end
end
