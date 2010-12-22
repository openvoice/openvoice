module FSR
  module Listener 

    def receive_data(data)
      FSR::Log.debug "Received #{data}"
    end

  end
end
class String
  alias :each :each_line
end
FSL = FSR::Listener
