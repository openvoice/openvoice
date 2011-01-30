require 'spec_helper'

include Authlogic::TestCase

describe MessagingsController do

  describe "HTML requests" do

    before do
      activate_authlogic
      @user = Factory.build(:user)
      @user.stub(:create_profile)
      @user.stub(:default_phone_number).and_return(valid_message_params[:from])
      UserSession.create(@user)
    end

    describe "GET index" do
      it "has a 200 status code" do
        get :index, {:user_id => @user.id}
        response.code.should eq("200")
      end
    end

    describe "POST create" do
#    let(:outgoing_call) { mock_model(OutgoingCall).as_null_object }

      before do
#      OutgoingCall.stub(:new).and_return(outgoing_call)
      end

      it "should create a new message" do
        pending
        Messaging.should_receive(:new) #.with(valid_message_params.merge({"user_id" => @user.id}))
        post :create, {:messaging => valid_message_params, :user_id => @user.id}
      end

      it "should save the outgoing_call" do
        pending
        outgoing_call.should_receive(:save)
        post :create, {:outgoing_call => valid_message_params, :user_id => @user.id}
      end

      context "when outgoing call is created successfully" do
        before do
          pending
          post :create, {:outgoing_call => valid_message_params, :user_id => @user.id}
        end

        it "sets a flash[:notice] message" do
          pending
          flash[:notice].should eq("VoiceCall was successfully created.")
        end

        it "redirects to OutgoingCall#index" do
          pending
          response.should redirect_to(:action => "index")
        end
      end

      context "when outgoing call cannot be created" do
        before do
          pending
          outgoing_call.stub(:save).and_return(false)
          post :create, {:outgoing_call => valid_message_params, :user_id => @user.id}
        end

        it "should assign an @outgoing_call" do
          pending
          assigns[:outgoing_call].should eq(outgoing_call)
        end

        it "should render the new template" do
          pending
          response.should render_template("new")
        end

        it "should display a flash[:error]" do
          pending
          flash[:error].should eq("Unable to place call.  Have you added a default phone number?")
        end

      end
    end
    
  end

  describe "JSON requests" do
    describe "POST create" do
      context "when there is insufficient parameters" do
        it "should display an error message if user_id is empty" do
          post :create, {:messaging => valid_message_params.merge(:user_id => ""), :format => 'json'}
          response.body.should == "authentication token is required to send messages, please log in first to obtain token."
        end

        it "should display an error message if user_id parameter is missing" do
          post :create, {:messaging => valid_message_params.delete(:user_id), :format => 'json'}
          response.body.should == "authentication token is required to send messages, please log in first to obtain token."
        end
      end
    end
  end

  private

  def valid_message_params()
    {
      :user_id => 1,
      :to   => "1234",
      :text => "foo",
      :from => "5678"
    }
  end
end