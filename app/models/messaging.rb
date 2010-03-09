class Messaging < ActiveRecord::Base
  after_create :send_text

  def send_text
    if outgoing
      msg_url = 'http://api.tropo.com/1.0/sessions?action=create&token=' + OUTBOUND_MESSAGING_TEMP + '&from='+ from + '&to=' + to + '&text=' + text
      open(msg_url) do |r|
        p r
      end
    end
  end
end
