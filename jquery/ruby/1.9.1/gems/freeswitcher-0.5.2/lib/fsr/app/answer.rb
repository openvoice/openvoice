
require "fsr/app"
module FSR
  module App
    class Answer < Application
      # Answer a call
     
      def initialize
      end

      def arguments
        []
      end

      def sendmsg
        "call-command: execute\nexecute-app-name: %s\n\n" % [app_name]
      end

    end

    register(:answer, Answer)
  end
end
