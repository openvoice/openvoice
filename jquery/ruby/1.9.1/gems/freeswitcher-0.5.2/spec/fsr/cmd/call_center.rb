require './spec/helper'
require "fsr/cmd"
FSR::Cmd.load_command("call_center")

describe "Testing FSR::Cmd::Callcenter" do
  ## Call Center ##
  # Interface to mod_callcenter
  it "FSR::Cmd::Callcenter should list agents " do
    cmd = FSR::Cmd::CallCenter.new nil, :agent
    cmd.list.raw.should == "callcenter_config agent list"
  end

  it "FSR::Cmd::Callcenter should add an agent defaulting callback" do
    cmd = FSR::Cmd::CallCenter.new nil, :agent
    cmd.add("1000@default").raw.should == "callcenter_config agent add '1000@default' callback"
  end

  it "FSR::Cmd::Callcenter should add an agent uuidstandby set" do
    cmd = FSR::Cmd::CallCenter.new nil, :agent
    cmd.add("1000@default", "uuid-standby").raw.should == "callcenter_config agent add '1000@default' uuid-standby"
  end

  it "FSR::Cmd::Callcenter should delete an agent " do
    cmd = FSR::Cmd::CallCenter.new nil, :agent
    cmd.del("1000@default").raw.should == "callcenter_config agent del 1000@default"
  end

  it "FSR::Cmd::Callcenter should set an attribute of an agent " do
    cmd = FSR::Cmd::CallCenter.new nil, :agent
    cmd.set("1000@default", :contact, 'user/1000').raw.should == "callcenter_config agent set contact '1000@default' 'user/1000'"
  end

  it "FSR::Cmd::Callcenter should set an attribute with dashes in it on an agent " do
    cmd = FSR::Cmd::CallCenter.new nil, :agent
    cmd.set("1000@default", :max_no_answer, 10).raw.should == "callcenter_config agent set max_no_answer '1000@default' 10"
  end

  it "FSR::Cmd::Callcenter should list tiers " do
    cmd = FSR::Cmd::CallCenter.new nil, :tier
    cmd.list("helpdesk@default").raw.should == "callcenter_config tier list helpdesk@default"
  end

  it "FSR::Cmd::Callcenter should add a tier " do
    cmd = FSR::Cmd::CallCenter.new nil, :tier
    cmd.add("1000@default", "helpdesk@default").raw.should == "callcenter_config tier add helpdesk@default 1000@default 1"
  end

  it "FSR::Cmd::Callcenter should delete a tier " do
    cmd = FSR::Cmd::CallCenter.new nil, :tier
    cmd.del("1000@default", "helpdesk@default").raw.should == "callcenter_config tier del helpdesk@default 1000@default"
  end

  it "FSR::Cmd::Callcenter should set an attribute of a tier entry " do
    cmd = FSR::Cmd::CallCenter.new nil, :tier
    cmd.set("1000@default", "helpdesk@default", :state, "Logged Out").raw.should == "callcenter_config tier set state helpdesk@default 1000@default 'Logged Out'"
  end

end
