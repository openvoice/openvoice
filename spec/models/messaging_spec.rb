require 'spec_helper'

describe Messaging do
  before(:each) do
    @caller_id = "14156667788"
    @user_id = 1
    @caller_name = "htc g1"
    @existing_contact = Contact.create({ :user_id => @user_id, :name => @caller_name, :number => @caller_id })
  end

  it "should set from_name for existing contact upon creation" do
    message = Messaging.create(:from => @caller_id, :user_id => @user_id)
    message.from_name.should == @caller_name
    Messaging.last.from_name.should == @caller_name
  end

  it "should set from_name to unknown caller for non-existing contact" do
    message = Messaging.create(:from => "whatever caller", :user_id => @user_id)
    message.from_name.should == "Unknown caller"
  end
end
