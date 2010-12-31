require 'spec_helper'

describe PhoneNumber do
  before(:each) do
    @user = Factory.build(:user)
    @pn = PhoneNumber.new(valid_phone_number_params)
    @pn.user = @user
  end

  describe "create" do
    it "should call sanitize_number" do
      @pn.should_receive(:sanitize_number)
      @pn.save!
    end

    it "should remove non-digits from user input" do
      @pn.number = "(340)123-1232"
      @pn.save!
      @pn.number.should eq("3401231232")
    end
  end

  def valid_phone_number_params
    {
       :number => "1234",
    }
  end

end
