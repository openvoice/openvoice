class VoiceCall < ActiveRecord::Base

  belongs_to :user

  after_create :dial

  def dial
    user_id = user.id
    from = user.phone_numbers.first.number
    call_url = 'http://api.tropo.com/1.0/sessions?action=create&token=' + OUTBOUND_TOKEN_VOICE + '&to=' + to + '&from=' + from + '&ov_action=call&user_id=' + user_id.to_s
    open(call_url)
  end

  # this is the old way of using the tropo helper hack to make outbound call
  def dial2
    call_url = 'http://api.tropo.com/1.0/sessions?action=create&token=' + OUTBOUND_VOICE_TEMP + '&to=' + to + '&from=' + user.phone_numbers.first.number
    open(call_url)
  end
end
