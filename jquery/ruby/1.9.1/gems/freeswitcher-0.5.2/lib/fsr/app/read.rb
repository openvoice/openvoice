require "fsr/app"
module FSR
    # http://wiki.freeswitch.org/wiki/Misc._Dialplan_Tools_read
  module App
    class Read < Application
      attr_reader :chan_var
      def initialize(sound_file, min = 0, max = 10, chan_var = "fsr_read_dtmf", timeout = 10000, terminators = ["#"])
        @sound_file, @min, @max, @chan_var, @timeout, @terminators = sound_file, min, max, chan_var, timeout, terminators
      end

      def arguments
        [@min, @max, @sound_file, @chan_var, @timeout, @terminators.join(",")]
      end

      def sendmsg
        "call-command: execute\nexecute-app-name: %s\nexecute-app-arg: %s\nevent-lock:true\n\n" % [app_name, arguments.join(" ")]
      end
      SENDMSG_METHOD = %q|
        def read(*args, &block)
          me = super(*args)
          @read_var = "variable_#{me.chan_var}"
          sendmsg me
          @queue.unshift Proc.new { update_session } 
          @queue.unshift(block_given? ? block : lambda {})
        end
      |
    end
    register(:read, Read)


  end
end
