require 'spec_helper'

describe Profile do
  before(:each) do
  end

  it "should remove white spaces in skype number" do
    pending
    profile = Profile.new
    profile.skype = "+1234 123"
    profile.save
    profile.skype.include?(" ").should be_false
  end

  it "should have error for invalid sip number" do
    pending
    profile = Profile.create(:sip => "af")
    profile.errors.should_not be_empty
    profile.should_not be_valid
  end

  it "should not have error for valid sip number" do
    pending
    profile = Profile.create(:sip => "sip:1234@foo.com")
    profile.errors.should be_empty
    profile.should be_valid    
  end

  describe "destroy" do
    it "should remove tropo numbers" do
      pending
    end
  end
end
