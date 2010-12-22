
require "fsr/app"
module FSR
  module App
    class Bridge < Application
      attr_reader :options

      def initialize(*params)
        @options = params.last.is_a?(Hash) ? params.pop : {}
        @sequential = @options.delete(:sequential)
        @targets = params
      end

      def arguments
        delimeter = @sequential ? "|" : ","
        [@targets.join(delimeter)]
      end

      def modifiers
        @options.map { |k,v| "%s=%s" % [k, v] }.join(",")
      end

      def raw
        "%s({%s}%s)" % [app_name, modifiers, arguments.join(" ")]
      end

      def self.execute(target, opts = {})
        self.new(target, opts).raw
      end
    end

    register(:bridge, Bridge)
  end
end
