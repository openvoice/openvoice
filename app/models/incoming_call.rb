class IncomingCall < ActiveRecord::Base

  belongs_to :user

  after_create :signal_tropo

  # signals tropo by making a session token call, passing ov_action=joinconf
  # when tropo response comes back, ov will put the user into an existing conference identified by conference_id
  def signal_tropo
    # TODO should add funtion that letting user to pick which phone to ring
    profile = user.profiles.first
    call_url = profile.call_url
    voice_token = profile.voice_token
    conf_id = user_id.to_s + "<--->" + caller_id
    tropo_url = (call_url || TROPO_URL) + voice_token + "&ov_action=joinconf&user_id=" + user.id.to_s \
                + "&conf_id=" + CGI::escape(conf_id) + "&caller_id=#{CGI::escape(caller_id)}" \
                + "&session_id=#{session_id}&call_id=#{call_id}"
    open(tropo_url)
  end

  def self.followme(params)
    user_id = params[:user_id]
    conf_id = params[:conf_id]
    caller_id = params[:caller_id]
    user = User.find(user_id)
    forwards = user.forwarding_numbers
    next_action = "/incoming_calls/user_menu?conf_id=#{CGI::escape(conf_id)}&user_id=#{user_id}&caller_id=#{CGI::escape(caller_id)}&session_id=#{params[:session_id]}&call_id=#{params[:call_id]}"
    tropo = Tropo::Generator.new do
      on(:event => 'continue', :next => next_action)
      call(:to => forwards)
      ask(:name => 'main-menu-incoming',
          :attempts => 3,
          :bargein => true,
          :choices => {:value => "connect(1), voicemail(2)", :mode => "DTMF"},
          :say => {:value => "Incoming call, press 1 to accept, press 2 to send to voicemail"})
    end
    tropo.response
  end

  def request_recording

  end

end
