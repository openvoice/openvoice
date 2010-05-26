class IncomingCall < ActiveRecord::Base

  belongs_to :user

  after_create :signal_tropo

  # signals tropo by making a session token call, passing ov_action=joinconf
  # when tropo response comes back, ov will put the user into an existing conference identified by conference_id
  def signal_tropo
    # TODO should add funtion that letting user to pick which phone to ring
    from = user.phone_numbers.first.number
    profile = user.profiles.first
    call_url = profile.call_url
    voice_token = profile.voice_token
    conf_id = user_id.to_s + "<--->" + caller_id
    tropo_url = (call_url || TROPO_URL) + voice_token + "&ov_action=joinconf&user_id=" + user.id.to_s + "&conf_id=" + CGI::escape(conf_id)
    open(tropo_url)
  end

  def self.followme(params)
    user_id = params[:user_id]
    conf_id = params[:conf_id]
    user = User.find(user_id)
    forwards = user.forwarding_numbers
    tropo = Tropo::Generator.new do
      on(:event => 'continue', :next => "#{SERVER_URL}/incoming_calls/joinconf?conf_id=#{CGI::escape(conf_id)}")
      call(:to => forwards)
      ask(:name => 'mainmenu',
          :attempts => 3,
          :bargein => true,
          :choices => {:value => "connect(1), voicemail(2)", :mode => "DTMF"},
          :say => {:value => "Incoming call, press 1 to accept."})
    end
    tropo.response
  end

  def request_recording

  end

end
