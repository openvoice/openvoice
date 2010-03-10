class User < ActiveRecord::Base
  acts_as_authentic

  has_many :phone_numbers
  has_many :voicemails
  has_many :messagings
  has_many :voice_calls
  
end
