class Messaging < ActiveRecord::Base

  belongs_to :user

  before_create :sanitize_numbers
  after_create :send_text

  def sanitize_numbers
    self.to.gsub!(/\D/, "")
    self.from.gsub!(/\D/, "")  
  end

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

  def created_at
    unless self.read_attribute(:created_at).nil?
      self.read_attribute(:created_at).strftime("%a, %b %d")
    end
  end

end
