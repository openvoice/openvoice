require 'fsr/command_socket'

class IncomingCall < ActiveRecord::Base

  belongs_to :user

  after_create :signal_tropo
  after_create :set_caller_name

  # signals tropo by making a session token call, passing ov_action=joinconf
  # when tropo response comes back, ov will put the user into an existing conference identified by conference_id
  def signal_tropo
    # TODO should add function that letting user to pick which phone to ring
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
    call_id = params[:call_id]
    session_id = params[:session_id]
    user = User.find(user_id)
    forwards = user.forwarding_numbers

    if (fsp = user.fs_profiles.first )
      fs_addr = fsp.sip_address
      dest = fs_addr.match(%r{(.*)@(.*)})[1].to_s + "%" + ENV['FS_HOST_IP']
      FSR.load_all_commands                           
      sock = FSR::CommandSocket.new(:server => ENV['FS_HOST'], :auth => ENV['FS_PASSWORD'])
      # TODO for now only allow calls from myopenvoice.org domain
      sock.originate(:target => "sofia/internal/1000%#{ENV['FS_HOST_IP']}", :endpoint =>FSR::App::Bridge.new("sofia/internal/#{dest}")).run
    end
    
    next_action = "/incoming_calls/user_menu?conf_id=#{CGI::escape(conf_id)}&user_id=#{user_id}&caller_id=#{caller_id}&session_id=#{session_id}&call_id=#{call_id}"
    contact = user.contacts.select{ |c| c.number == caller_id }.first
    contact = Contact.last if contact.nil?
    name_recording = contact.name_recording ||"Unannounced caller"
#    signal_url = "signal_peer?event=disconnect&call_id=#{call_id}&session_id=#{session_id}"
    tropo = Tropo::Generator.new do
      on(:event => 'continue', :next => next_action)
#      on(:event => 'error', :next => signal_url)
#      on(:event => 'incomplete', :next => signal_url)
#      on(:event => 'hangup', :next => signal_url)
      call(:to => forwards, :from => caller_id)
      ask(:name => 'main-menu-incoming',
          :attempts => 3,
          :bargein => true,
          :choices => {:value => "connect(1), voicemail(2), listenin(3)", :mode => "DTMF"},
          :say => {:value => "Incoming call from #{name_recording} , press 1 to accept, press 2 to send to voicemail, press 3 to listen in. "})
    end
    tropo.response
  end

  # Looks up contact name by caller_id and set it for every incoming message
  def set_caller_name
    caller = user.contacts.select{ |c| c.number == caller_id }.first
    unless caller.nil?
      update_attribute(:caller_name, caller.name)
    else
      update_attribute(:caller_name, "Unknown caller")
    end
  end

  def created_at
    unless self.read_attribute(:created_at).nil?
      self.read_attribute(:created_at).strftime("%a, %b %d")
    end
  end

  def hangup
    Tropo::Generator.new{ hangup }.to_json
  end

#  def signal_peer
#    tropo_url = "http://api.tropo.com/1.0/sessions/#{params[:session_id]}/calls/#{params[:call_id]}/events?action=create&name=#{event}"
#    open(tropo_url)
#    render head 204
#  end
end
