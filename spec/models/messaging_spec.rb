require 'spec_helper'

describe Messaging do
  before(:each) do
    @user = Factory.build(:user)
    @message = Messaging.new(valid_message_params)
    @message.stub(:send_text)
    @message.user = @user
    @caller_name = "htc g1"
    @existing_contact = Contact.create!({:user_id => @user.id, :name => @caller_name, :number => valid_message_params[:from]})
    @user.contacts << @existing_contact
  end

  describe "create" do
    it "should call set_from_name" do
      @message.should_receive(:set_from_name)
      @message.save!
    end

    it "should set from_name for existing contact upon creation" do
      @message.save!
      @message.from_name.should == @caller_name
    end

    it "should set from_name to unknown caller for non-existing contact" do
      @message.from = "anon"
      @message.save!
      @message.from_name.should == "Unknown caller"
    end

    it "should set from_name to originator for outgoing messages" do
      @message.outgoing= true
      @message.save!
      @message.from_name.should eq("You")
    end
  end

  describe "create replies" do
    it "should set in_reply_to_id" do
      @message.save!
      @reply = @message.create_reply(valid_reply_params)
      @reply.in_reply_to_id.should eq(@message.id)
    end
  end

  def valid_message_params
    {
       :to => "1234",
       :text => "foo",
       :from => "5678"
    }
  end

  def valid_reply_params
    {
       :to => "5678",
       :text => "bar",
       :from => "1234"
    }
  end
end
