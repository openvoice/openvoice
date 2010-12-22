require_relative "../model"
module FSR
  module Model
    class Queue
      attr_reader :fields
      include FSR::Model
      def initialize(headers, *data)
        @fields = headers
        @fields.each_with_index do |h,i| 
          (class << self; self; end).send(:define_method,h.to_sym) { data[i] }
        end
      end
    end
  end
end
