require 'spec_helper'

include Authlogic::TestCase

describe OutgoingCallsController do
  before(:each) do
    activate_authlogic
    @user = Factory.build(:user)
    @user.stub(:create_profile)
    UserSession.create(@user)
  end

  describe "GET index" do
    it "has a 200 status code" do
      get :index, {:user_id => @user.id}
      response.code.should eq("200")
    end
  end

  describe "POST create" do
    let(:outgoing_call) { mock_model(OutgoingCall).as_null_object }
    before do
      OutgoingCall.stub(:new).and_return(outgoing_call)
    end

    it "should create a new OutgoingCall" do
      OutgoingCall.should_receive(:new).with(valid_outgoing_call_params.merge({"user_id" => @user.id}))
      post :create, {:outgoing_call => valid_outgoing_call_params, :user_id => @user.id}
    end

    it "should save the outgoing_call" do
      outgoing_call.should_receive(:save) 
      post :create, {:outgoing_call => valid_outgoing_call_params, :user_id => @user.id}
    end
  end

  private

  def valid_outgoing_call_params()
    {
        "callee_number" => "18887770000"
    }
  end

end