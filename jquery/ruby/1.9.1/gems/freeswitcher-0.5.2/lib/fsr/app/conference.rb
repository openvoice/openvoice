
require "fsr/app"
module FSR
  module App
    class Conference < Application
      attr_reader :target, :profile

      def initialize(conference_name, conference_profile = nil)
        # These are options that will precede the target address
        @target = conference_name
        @profile = conference_profile || "ultrawideband"
      end

      def arguments
        ["%s@%s" % [@target, @profile]]
      end

      def self.execute(conference_name, conference_profile = nil)
        self.new(conference_name, conference_profile).raw
      end

      def self.[](conference_name)
        self.execute(conference_name)
      end
    end

    register(:conference, Conference)
  end
end
