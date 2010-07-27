class Profile < ActiveRecord::Base
  belongs_to :user

  validates_format_of :sip, :with => /(\Asip:)(.*)@(.*)/, :on => :create, :allow_nil => true, :allow_blank => true
  validates_presence_of :call_url
  validates_presence_of :voice_token
  validates_presence_of :messaging_token
  
  before_create :sanitize_numbers

  def sanitize_numbers
    skype.gsub!(" ", "") unless skype.nil?
  end
end
