class Profile < ActiveRecord::Base
  belongs_to :user

  validates_format_of :sip, :with => /(\Asip:)(.*)@(.*)/, :on => :create, :allow_nil => true, :allow_blank => true

  before_create :sanitize_numbers

  def sanitize_numbers
    skype.gsub!(" ", "") unless skype.nil?
  end
end
