require "fsr/app"
module FSR
  module App
    class Limit < Application

      def initialize(id = nil, realm = "$${domain}", limit = 5)
        @realm, @id, @limit = realm, id, limit
        raise "Must supply a valid id" if @id.nil?
      end

      def arguments
        [@realm, @id, @limit]
      end

    end

    register(:limit, Limit)
  end
end
