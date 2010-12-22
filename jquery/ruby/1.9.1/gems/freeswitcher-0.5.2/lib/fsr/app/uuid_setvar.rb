require "fsr/app"
module FSR
  #http://wiki.freeswitch.org/wiki/Mod_commands#uuid_setvar
  module App
    class UuidSetVar < Application
      attr_reader :var, :uuid, :assignment

      def initialize(uuid, var, assignment)
        @uuid = uuid # Unique channel ID
        @var = var # Channel variable you wish to 'set'
        @assignment = assignment
      end

      def arguments
        [@uuid, @var, @assignment]
      end

      def sendmsg
        "call-command: execute\nexecute-app-name: %s\nexecute-app-arg: %s\nevent-lock:true\n\n" % [app_name, arguments.join(" ")]
      end

      SENDMSG_METHOD = %q|
        def uuid_setvar(*args, &block)
          me = super(*args)
          api_call = "api uuid_setvar #{me.uuid} #{me.var} #{me.assignment}\n\n"
          send_data(api_call) 
          @queue.unshift block if block_given?
        end
      |
    end

    register(:uuid_setvar, UuidSetVar)
  end
end
