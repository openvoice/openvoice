class VoiceCall < ActiveRecord::Base

  belongs_to :user

  before_create :sanitize_numbers
  after_create :dial

  def sanitize_numbers
    self.to && self.to.gsub!(/\D/, "")
  end
  
  def dial
    user_id = user.id.to_s
    # TODO should add funtion that letting user to pick which phone to ring
    from = user.phone_numbers.first.number
    profile = user.profiles.first
    call_url = profile.call_url
    voice_token = profile.voice_token
    tropo_url = (call_url || TROPO_URL) + voice_token + '&to=' + to + '&from=' + from + '&ov_action=call&user_id=' + user_id
    open(tropo_url)
  end

  def created_at
    unless self.read_attribute(:created_at).nil?
      self.read_attribute(:created_at).strftime("%a, %b %d")
    end
  end
  
end
