class CallLog < ActiveRecord::Base
  belongs_to :user

  def created_at
    unless self.read_attribute(:created_at).nil?
      self.read_attribute(:created_at).strftime("%a, %b %d")
    end
  end
  
end
