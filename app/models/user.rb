class User < ActiveRecord::Base
  acts_as_authentic

  has_many :phone_numbers,  :dependent => :destroy
  has_many :voicemails,     :dependent => :destroy
  has_many :messagings,     :dependent => :destroy
  has_many :outgoing_calls, :dependent => :destroy
  has_many :incoming_calls, :dependent => :destroy
  has_many :contacts,       :dependent => :destroy
  has_many :profiles,       :dependent => :destroy
  has_many :fs_profiles,    :dependent => :destroy

  attr_accessor :prefix
  attr_accessor :default_number

  after_create :create_profile
  after_create :create_default_phone_number

  validates_presence_of :default_number
  
  # returns the default phone to ring, if user defines multiple default phones, then pick the first one;
  # if user does not define a default, then just pick the first forwarding phone;
  # if user does not define a forwarding phone, just pick the first phone number;
  # if user does not define any phone yet, returns an error message
  def default_phone_number
    return nil if phone_numbers.empty?
    defaults = phone_numbers.select{ |n| n.default == true }
    return defaults.first.number unless defaults.empty?
    forwards = phone_numbers.select{ |n| n.forward == true }
    return forwards.first.number unless forwards.empty?
    return phone_numbers.first.number
  end

  # returns all the forward phone_numbers
  def forwarding_numbers
    numbers = phone_numbers.select{ |n| n.forward == true }.map(&:number)
    numbers << profiles.first.phono_sip_address if profiles.first && profiles.first.phono_sip_address
    numbers
  end

  def create_profile
    tu = ENV["TROPO_USER"]
    tp = ENV["TROPO_PASS"]
    ta = Rails.env == "development" ? "139325" : ENV["TROPO_APP"]
    tp = TropoProvisioning.new(tu, tp)
    address_data = tp.create_address(ta, { :type => 'number', :prefix => @prefix })
    new_number = address_data.address.gsub("+1", "")
    profile = profiles.build(:voice => new_number,
                             :voice_token => OUTBOUND_TOKEN_VOICE,
                             :messaging_token => OUTBOUND_TOKEN_MESSAGING,
                             :call_url => TROPO_URL)
    profile.save
  end

  def create_default_phone_number
    pn = PhoneNumber.new({:user_id => self.id, :number => self.default_number, :forward => true, :default => true, :name => "default"})
    pn.save 
  end

  def usa_numbers
    TropoUtils.available_numbers
  end
end
