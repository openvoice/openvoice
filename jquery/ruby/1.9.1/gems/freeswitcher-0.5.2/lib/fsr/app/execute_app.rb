require "fsr/app"
module FSR
  module App
    # http://wiki.freeswitch.org/wiki/Misc._Dialplan_Tools_log
    class ExecuteApp < Application
      attr_reader :app_name, :arguments
      def initialize(app, *args)
        @app_name = app
        @arguments = args
      end
    end

    register(:execute_app, ExecuteApp)
  end
end
