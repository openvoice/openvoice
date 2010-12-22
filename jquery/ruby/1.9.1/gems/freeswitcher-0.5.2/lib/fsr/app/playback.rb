require "fsr/app"
require 'fsr/file_methods'
module FSR
  module App
    class Playback < Application

      include ::FSR::App::FileMethods

      attr_reader :wavfile

      def initialize(wavfile)
        # wav file you wish to play, full path
        test_files wavfile
        @wavfile = wavfile
      end

      def arguments
        @wavfile
      end

      def sendmsg
        "call-command: execute\nexecute-app-name: %s\nexecute-app-arg: %s\nevent-lock:true\n\n" % [app_name, arguments]
      end
    end

    register(:playback, Playback)
  end
end
