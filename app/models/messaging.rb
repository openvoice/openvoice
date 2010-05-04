class Messaging < ActiveRecord::Base
  after_create :send_text

  def send_text
    if outgoing
      msg_url = 'http://api.tropo.com/1.0/sessions?action=create&token=' + OUTBOUND_TOKEN_MESSAGING + '&from='+ from + '&to=' + to + '&text=' + CGI::escape(text)
      open(msg_url)
    end
  end

  def send_text1
    if outgoing
      msg_url = 'http://api.tropo.com/1.0/sessions?action=create&token=' + OUTBOUND_MESSAGING_TEMP + '&from='+ from + '&to=' + to + '&text=' + CGI::escape(text)
      open(msg_url)
    end
  end
end
