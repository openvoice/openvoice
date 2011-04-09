require 'spec_helper'

include Authlogic::TestCase

describe CallsController do
  before do
    activate_authlogic
    @user = Factory.build(:user)
    @user.stub(:create_profile)
    UserSession.create(@user)

    @ic1 = Factory.build(:incoming_call, :user_id => 1, :updated_at => 1.minute.ago)
    @ic2 = Factory.build(:incoming_call, :user_id => 1, :updated_at => 3.minute.ago)
    @ic1.stub(:signal_tropo)                             
    @ic2.stub(:signal_tropo)
    @incoming_calls = [@ic1, @ic2]

    @oc1 = Factory.build(:outgoing_call, :user_id => 1, :updated_at => 2.minute.ago)
    @oc2 = Factory.build(:outgoing_call, :user_id => 1, :updated_at => 4.minute.ago)
    @oc1.stub(:has_phone_number?).and_return(true)
    @oc2.stub(:has_phone_number?).and_return(true)
    @oc1.stub(:dial)
    @oc2.stub(:dial)
    @outgoing_calls = [@oc1, @oc2]

    @user.incoming_calls = @incoming_calls
    @user.outgoing_calls = @outgoing_calls

    get :index, :user_id => @user.id
  end

  it "should succeed" do
    response.should be_success
  end

  it "should contain both incoming and outgoing calls ordered by time" do
    calls = assigns(:calls)
    calls.should == [@ic1, @oc1, @ic2, @oc2]
  end

end