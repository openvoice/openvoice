class IncomingCall < ActiveRecord::Base

  belongs_to :user

  after_create :signal_tropo
  after_create :set_caller_name

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
    caller_id = CGI::escape(params[:caller_id])
    user = User.find(user_id)
    forwards = user.forwarding_numbers
    next_action = "/incoming_calls/user_menu?conf_id=#{CGI::escape(conf_id)}&user_id=#{user_id}&caller_id=#{caller_id}&session_id=#{params[:session_id]}&call_id=#{params[:call_id]}"
    name_recording = "#{SERVER_URL}/contacts/get_name_recording?user_id=#{user_id}&amp;caller_id=#{caller_id}"
    p "++++++++++++++++++++++++++++++++++++++++"
    p name_recording
    p "++++++++++++++++++++++++++++++++++++++++"
    tropo = Tropo::Generator.new do
      on(:event => 'continue', :next => next_action)
      call(:to => forwards)
      ask(:name => 'main-menu-incoming',
          :attempts => 3,
          :bargein => true,
          :choices => {:value => "connect(1), voicemail(2)", :mode => "DTMF"},
          :say => {:value => "Incoming call from #{name_recording} , press 1 to accept, press 2 to send to voicemail"})
    end
    tropo.response
  end

  # Looks up contact name by caller_id and set it for every incoming message
  def set_caller_name
    caller = Contact.find_by_number(caller_id)
    if caller
      self.caller_name = caller.name
    else
      self.caller_name = "Unknown caller"
    end
  end

  def created_at
    unless self.read_attribute(:created_at).nil?
      self.read_attribute(:created_at).strftime("%a, %b %d")
    end
  end
  
end
