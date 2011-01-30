require 'spec_helper'

describe UserSessionsController do
  before do
    @user = Factory.build(:user)
  end

  describe "successful login" do
    before do
      post :create, valid_params
    end

    it "should have response code of 200" do
      response.should be_redirect
    end
  end

  describe "failed login" do
    context "when username and password "
  end

  def valid_params
    {
      :user_session => {:login => @user.login, :password => @user.password}
    }
  end
end
