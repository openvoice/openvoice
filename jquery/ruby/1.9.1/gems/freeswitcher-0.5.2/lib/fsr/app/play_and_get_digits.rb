require "fsr/app"
require 'fsr/file_methods'

module FSR
  #http://wiki.freeswitch.org/wiki/Misc._Dialplan_Tools_play_and_get_digits
  module App
    class PlayAndGetDigits < Application

      include ::FSR::App::FileMethods

      attr_reader :chan_var
      DEFAULT_ARGS = {:min => 0, :max => 10, :tries => 3, :timeout => 7000, :terminators => ["#"], :chan_var => "fsr_read_dtmf", :regexp => '\d'}

      # args format for array:
      # sound_file, invalid_file, min = 0, max = 10, tries = 3, timeout = 7000, terminators = ["#"], chan_var = "fsr_read_dtmf", regexp = '\d'
      def initialize(sound_file, invalid_file, *args)
        #puts args.inspect
        if args.size == 1 and args.first.kind_of?(Hash)
          arg_hash = DEFAULT_ARGS.merge(args.first)
        elsif args.size > 0
          # The array used to .zip the args here can be replaced with DEFAULT_ARGS.keys if Hash keys are ordered (1.9)
          # For now we'll hard code them to preserve order in 1.8/jruby
          arg_hash = DEFAULT_ARGS.merge(Hash[[:min, :max, :tries, :timeout, :terminators, :chan_var, :regexp][0 .. (args.size-1)].zip(args)]) 
        elsif args.size == 0
          arg_hash = DEFAULT_ARGS
        else
          raise "Invalid Arguments for PlayAndGetDigits#new (must pass (sound_file, invalid_file, hash) or (sound_file, invalid_file, min = 0, max = 10, tries = 3, timeout = 7000, terminators = ['#'], chan_var = 'fsr_read_dtmf', regexp = '\d'))"
        end
        @sound_file = sound_file
        @invalid_file = invalid_file
        @min = arg_hash[:min]
        @max = arg_hash[:max]
        @tries = arg_hash[:tries]
        @timeout = arg_hash[:timeout]
        @chan_var = arg_hash[:chan_var]
        @terminators = arg_hash[:terminators]
        @regexp = arg_hash[:regexp]

        raise unless test_files(@sound_file, @invalid_file)

      end

      def arguments
        [@min, @max, @tries, @timeout, @terminators.join(","), @sound_file, @invalid_file, @chan_var, @regexp]
      end

      def sendmsg
        "call-command: execute\nexecute-app-name: %s\nexecute-app-arg: %s\nevent-lock:true\n\n" % ["play_and_get_digits", arguments.join(" ")]
      end
      SENDMSG_METHOD = %q|
        def play_and_get_digits(*args, &block)
          me = super(*args)
          @read_var = "variable_#{me.chan_var}"
          sendmsg me
          @queue.unshift Proc.new { update_session } 
          @queue.unshift(block_given? ? block : lambda {})
        end
      |
    end

    register(:play_and_get_digits, PlayAndGetDigits)
  end
end
