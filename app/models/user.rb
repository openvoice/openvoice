class User < ActiveRecord::Base
  acts_as_authentic

  has_many :phone_numbers
  has_many :voicemails
  has_many :messagings
  has_many :outgoing_calls
  has_many :incoming_calls
  has_many :contacts
  has_many :profiles
  has_many :fs_profiles

  after_create :create_profile

  # returns the default phone to ring, if user defines multiple default phones, then pick the first one;
  # if user does not define a default, then just pick the first forwarding phone;
  # if user does not define a forwarding phone, just pick the first phone number;
  # if user does not define any phone yet, returns an error message
  def default_phone_number
    return "Please add a phone number to OpenVoice" if phone_numbers.empty?
    defaults = phone_numbers.select{ |n| n.default == true }
    return defaults.first.number unless defaults.empty?
    forwards = phone_numbers.select{ |n| n.forward == true }
    return forwards.first.number unless forwards.empty?
    return phone_numbers.first.number
  end

  # returns all the forward phone_numbers
  def forwarding_numbers
    phone_numbers.select{ |n| n.forward == true }.map(&:number)
  end

  def create_profile
    tu = ENV['TROPO_USER']
    tp = ENV['TROPO_PASS']
    ta = ENV["TROPO_APP"]
    url = "http://" + tu + ":" + tp + "@api.tropo.com/provisioning/applications/" + ta + "/addresses/"
    resp = RestClient.post(url, { :type => "number" }.to_json, :content_type => :json, :accept => :json )
    new_number = JSON.parse(resp.body)["href"].match(%r{(.*/)(.*)})[2]
    profile = profiles.build(:voice => new_number,
                             :voice_token => OUTBOUND_TOKEN_VOICE,
                             :messaging_token => OUTBOUND_TOKEN_MESSAGING,
                             :call_url => TROPO_URL)
    profile.save
  end
end
