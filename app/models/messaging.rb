class Messaging < ActiveRecord::Base

  belongs_to :user

  after_create :send_text

  def send_text
    if outgoing
      from = user.phone_numbers.first.number
      profile = user.profiles.first
      call_url = profile.call_url
      messaging_token = profile.messaging_token
      msg_url = (call_url || TROPO_URL) + messaging_token + '&from='+ from + '&to=' + to + '&text=' + CGI::escape(text)
      open(msg_url)
    end
  end

end
