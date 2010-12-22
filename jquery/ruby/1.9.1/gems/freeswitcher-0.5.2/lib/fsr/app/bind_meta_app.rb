
require "fsr/app"
module FSR
  module App
    class BindMetaApp < Application
      attr_reader :options

      def initialize(args)
        @options = args
      end

      # It would be better to fix App#app_name to transform
      # CamelCase to snake_case, but that'll be later.
      def app_name
        "bind_meta_app"
      end

      def arguments
        parameters = options[:parameters] ? "::#{options[:parameters]}" : ""
        [options[:key], options[:listen_to], options[:respond_on], options[:application] + parameters]
      end
    end

    register(:bind_meta_app, BindMetaApp)
  end
end
