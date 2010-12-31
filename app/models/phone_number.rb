class PhoneNumber < ActiveRecord::Base
  
  belongs_to :user

  validates_presence_of :user
  validates_presence_of :number

  before_create :sanitize_number

  def sanitize_number
    self.number.gsub!(/\D/, "") if self.number
  end

end
