class Voicemail < ActiveRecord::Base
  belongs_to :user

  validates_presence_of :user

#  has_attachment :storage => :s3
end
