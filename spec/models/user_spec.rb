require 'spec_helper'

describe User do
  before(:each) do
    @phone_number = "1234"
    @user = Factory.build(:user)
    @user.default_number = @phone_number
    @user.stub(:create_profile)
  end

  describe "create" do
    it "should receive :create_default_phone_number" do
      @user.should_receive(:create_default_phone_number)
      @user.save!
    end

    it "should create a default phone number" do
      lambda {
        @user.save!
      }.should change(@user.phone_numbers, :count).by(1)
    end

    it "should require a default phone number" do
      @user.default_number = nil
      @user.should_not be_valid
    end
  end
end