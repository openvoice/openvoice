
require "fsr/app"
module FSR
  module App
    class FSBreak < Application
      def initialize
      end

      def arguments
        []
      end

      def sendmsg
        "call-command: execute\nexecute-app-name: break\n\n"
      end

    end

    register(:fs_break, FSBreak)
  end
end
