class OutgoingCall < ActiveRecord::Base
  include ActionView::Helpers::DateHelper

  belongs_to :user

  before_create :has_phone_number?
  before_create :sanitize_numbers
  after_create :dial

  def has_phone_number?
    !user.default_phone_number.nil?
  end

  def sanitize_numbers
    self.callee_number && self.callee_number.gsub!(/\D/, "")
  end

  def dial
    user_id = user.id.to_s
    # TODO should add function that letting user to pick which phone to ring
    from = user.default_phone_number
    ov_voice = user.profiles.first.voice
    profile = user.profiles.first
    call_url = profile.call_url
    voice_token = profile.voice_token
    tropo_url = (call_url || TROPO_URL) + voice_token + '&to=' + callee_number + '&from=' + from + '&ov_action=outboundcall&user_id=' + user_id + '&ov_voice=' + ov_voice
    HTTParty.get(tropo_url)
  end

  # perform tropo call transfer
  def self.init_call(params)
    # call OV user first, once user answers, transfers the call to the destination number
    ov_voice = params[:ov_voice]
    default_number = params[:from]
    destination = params[:to]
    tropo = Tropo::Generator.new do
      call({ :from => ov_voice,
             :to => default_number,
             :network => 'PSTN',
             :channel => 'VOICE' })
      say 'connecting you to destination'
      transfer({ :to => destination, :from => ov_voice })
    end

    tropo.response
  end

  def callee_name
    if (contact = user.contacts.select{|c| c.number == self.callee_number}.first)
      contact.name
    else
      ""
    end
  end

  def created_at
    unless self.read_attribute(:created_at).nil?
      self.read_attribute(:created_at).strftime("%a, %b %d")
    end
  end

  def date_for_stream
    "#{time_ago_in_words(updated_at)} ago"
  end

end
