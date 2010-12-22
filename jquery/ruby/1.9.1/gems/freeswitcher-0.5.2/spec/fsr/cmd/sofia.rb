require 'spec/helper'
require "fsr/cmd"
FSR::Cmd.load_command("sofia")

describe "Testing FSR::Cmd::Sofia" do
  ## Sofia ##
  # Interface to sofia
  it "FSR::Cmd::Sofia should interface to sofia" do
    sofia = FSR::Cmd::Sofia.new
    sofia.raw.should == "sofia"
  end

  ## Sofia Status ##
  it "FSR::Cmd::Sofia should allow status" do
    sofia = FSR::Cmd::Sofia.new
    status = sofia.status
    status.raw.should == "sofia status"
  end
  # Sofia status profile internal
  it "FSR::Cmd::Sofia should allow status profile internal" do
    sofia = FSR::Cmd::Sofia.new
    status = sofia.status(:status => 'profile', :name => 'internal')
    status.raw.should == "sofia status profile internal"
  end
  # Sofia status gateway server 
  it "FSR::Cmd::Sofia should allow status gateway server" do
    sofia = FSR::Cmd::Sofia.new
    status = sofia.status(:status => 'gateway', :name => 'server')
    status.raw.should == "sofia status gateway server"
  end

  ## Sofia profile ##
  it "FSR::Cmd::Sofia should allow profile" do
    sofia = FSR::Cmd::Sofia.new
    profile = sofia.profile
    profile.raw.should == "sofia profile"
  end

  it "FSR::Cmd::Sofia::Profile should allow raw string" do
    sofia = FSR::Cmd::Sofia.new
    profile = sofia.profile('internal stop')
    profile.raw.should == "sofia profile internal stop"
  end

  it "FSR::Cmd::Sofia::Profile should allow start" do
    sofia = FSR::Cmd::Sofia.new
    profile = sofia.profile.start('internal')
    profile.raw.should == "sofia profile internal start"
  end

  it "FSR::Cmd::Sofia::Profile should allow stop" do
    sofia = FSR::Cmd::Sofia.new
    profile = sofia.profile.stop('internal')
    profile.raw.should == "sofia profile internal stop"
  end

  it "FSR::Cmd::Sofia::Profile should allow restart" do
    sofia = FSR::Cmd::Sofia.new
    profile = sofia.profile.restart('internal')
    profile.raw.should == "sofia profile internal restart"
  end

  it "FSR::Cmd::Sofia::Profile should allow rescan" do
    sofia = FSR::Cmd::Sofia.new
    profile = sofia.profile.rescan('internal')
    profile.raw.should == "sofia profile internal rescan"
  end

end
