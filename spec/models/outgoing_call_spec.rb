require 'spec_helper'

describe OutgoingCall do
  before(:each) do
    @user = Factory.build(:user)
    @outgoing_call = OutgoingCall.new(:callee_number => "1234")
    @outgoing_call.user = @user
    @user.stub(:create_profile).and_return(true)
    @user.stub(:default_phone_number).and_return(nil)
  end

  it "should not save without a default phone number" do
    @outgoing_call.save.should == false
  end
end