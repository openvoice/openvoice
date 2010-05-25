class IncomingCall < ActiveRecord::Base

  belongs_to :user

  def init_transfer
    user_id = user.id.to_s
    # TODO should add funtion that letting user to pick which phone to ring
    from = user.phone_numbers.first.number
    profile = user.profiles.first
    call_url = profile.call_url
    voice_token = profile.voice_token
    tropo_url = (call_url || TROPO_URL) + voice_token + '&to=' + callee_number + '&from=' + from + '&ov_action=incoming&user_id=' + user_id
    open(tropo_url)
  end

  def request_recording

  end

  def self.followme
    tropo = Tropo::Generator.new do
      say("Please wait while we connect your call")
      conference( :name => "conference", :id => "foobar", :terminator => "*")
    end

    tropo.response
  end

  def create_conference

  end
end
