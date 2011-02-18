require 'spec_helper'

describe VoicemailsController do

  before do
    @user = Factory.build(:user)
    @user.stub!(:default_number).and_return("16501112222")
    @user.stub!(:create_profile).and_return(true)
    @user.save!
  end

  describe "#create" do
    subject {post :create, :user_id => @user.id, :transcription_id => "fake_id", :filename => fixture_file_upload('spec/files/fake_file')}
    
    it "should succeed" do
      subject
      response.should be_success
    end

    it "should create a new voicemail" do
      lambda {
        subject
      }.should change{Voicemail.count}.by(1)
    end
  end
end
