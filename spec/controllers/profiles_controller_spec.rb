require 'spec_helper'

include Authlogic::TestCase

describe ProfilesController do
  before do
    activate_authlogic
    @user = Factory.build(:user)
    @user.stub(:create_profile)
    UserSession.create(@user)

    @profile = Factory(:profile)
    @user.profiles << @profile

    @valid_profile_params = {
      :messaging_token => @profile.messaging_token,
      :voice_token     => @profile.voice_token,
      :call_url        => @profile.call_url
    }
  end

  describe "HTML requests" do
    describe "GET index" do
      before do
        get :index, :user_id => @user.to_param
      end

      it "should succeed" do
        response.should be_success
      end

      it "should return 1 profile" do
        assigns(:profiles).should == [@profile]
      end
    end

    describe "PUT update" do
      context "when updating phone_sip_address" do
        let(:phono_sip_address) {"sip:phone_sip_address.com"}
        subject {put :update, :user_id => @user.to_param, :id => @profile.to_param, :profile => {:phono_sip_address => phono_sip_address}}

        it "should redirect to user's profiles page" do
          subject
          response.should redirect_to(user_profiles_path(@user))
        end

        it "should have a flash notice" do
          subject
          flash[:notice].should eq("Profile was updated successfully.")
        end

        it "should update the phono_sip_address of the profile" do
          lambda {
            subject
          }.should change{@profile.reload.phono_sip_address}.from(nil).to(phono_sip_address)
        end
      end
    end
  end
end
