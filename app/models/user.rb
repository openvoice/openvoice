class User < ActiveRecord::Base
  acts_as_authentic

  has_many :phone_numbers
  
end
