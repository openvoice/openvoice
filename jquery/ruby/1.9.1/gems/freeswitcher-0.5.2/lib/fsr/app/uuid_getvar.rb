require "fsr/app"
module FSR
  #http://wiki.freeswitch.org/wiki/Mod_commands#uuid_setvar
  module App
    class UuidGetVar < Application
      attr_reader :var, :uuid

      def initialize(uuid, var)
        @uuid = uuid # Unique channel ID
        @var = var # Channel variable you wish to 'set'
      end

      def arguments
        [@uuid, @var]
      end

      def sendmsg
        "call-command: execute\nexecute-app-name: %s\nexecute-app-arg: %s\nevent-lock:true\n\n" % [app_name, arguments.join(" ")]
      end

      SENDMSG_METHOD = %q|
        def uuid_getvar(*args, &block)
          me = super(*args)
          @uuid_var = me.var
          api_call = "api uuid_getvar #{me.uuid} #{me.var}\n\n"
          send_data(api_call) 
          @queue.unshift block if block_given?
        end
      |
    end

    register(:uuid_getvar, UuidGetVar)
  end
end
