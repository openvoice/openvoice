class VoiceCall < ActiveRecord::Base

  belongs_to :user

  after_create :dial

  def dial
    user_id = user.id.to_s
    from = user.phone_numbers.first.number
    profile = user.profiles.first
    call_url = profile.call_url
    voice_token = profile.voice_token
    tropo_url = (call_url || TROPO_URL) + voice_token + '&to=' + to + '&from=' + from + '&ov_action=call&user_id=' + user_id
    open(tropo_url)
  end
end
