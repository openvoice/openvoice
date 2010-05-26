class Voicemail < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :user

  def created_at
    unless self.read_attribute(:created_at).nil?
      self.read_attribute(:created_at).strftime("%a, %b %d")
    end
  end

end
