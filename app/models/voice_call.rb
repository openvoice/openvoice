class VoiceCall < ActiveRecord::Base

  after_create :dial

  def dial
    call_url = 'http://api.tropo.com/1.0/sessions?action=create&token=' + OUTBOUND_VOICE_TEMP + '&to=' + to
    open(call_url) do |r|
      p r
    end
  end
end
