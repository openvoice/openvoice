module FSR
  module Listener
    # This module is intended to be used with em-spec
    module Mock

      def send_data(data)
        sent_data << data
      end
      
      def sent_data
        @sent_data ||= []
      end
      
      def receive_reply(reply)
        replies << reply
      end
      
      def replies
        @recvd_reply ||= []
      end
    end
  end
end
