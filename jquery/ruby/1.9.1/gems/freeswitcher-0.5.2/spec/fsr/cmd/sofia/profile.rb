require 'spec/helper'
require "fsr/cmd"
FSR::Cmd.load_command("sofia")

describe "FSR::Cmd::Sofia::Profile" do

  ## Sofia profile ##
  it "should allow FSR::Cmd::Sofia.new.profile (no arguments) through Sofia instance" do
    sofia = FSR::Cmd::Sofia.new
    profile = sofia.profile
    profile.raw.should == "sofia profile"
  end

  it "should allow raw string as an argument through Sofia instance" do
    sofia = FSR::Cmd::Sofia.new
    profile = sofia.profile('internal stop')
    profile.raw.should == "sofia profile internal stop"
  end

  it "should start a profile by name through Sofia instance" do
    sofia = FSR::Cmd::Sofia.new
    profile = sofia.profile.start('internal')
    profile.raw.should == "sofia profile internal start"
  end

  it "should stop a profile by name through Sofia instance" do
    sofia = FSR::Cmd::Sofia.new
    profile = sofia.profile.stop('internal')
    profile.raw.should == "sofia profile internal stop"
  end

  it "should restart a profile by name through Sofia instance" do
    sofia = FSR::Cmd::Sofia.new
    profile = sofia.profile.restart('internal')
    profile.raw.should == "sofia profile internal restart"
  end

  it "should rescan a profile by name through Sofia instance" do
    sofia = FSR::Cmd::Sofia.new
    profile = sofia.profile.rescan('internal')
    profile.raw.should == "sofia profile internal rescan"
  end

  it "should start, stop, rescan, restart a profile by name with a class method" do
    # pass nil as the socket until we get the MockSocket completed
    FSR::Cmd::Sofia::Profile.start("foo", nil).raw.should == "sofia profile foo start"
    FSR::Cmd::Sofia::Profile.stop("foo", nil).raw.should == "sofia profile foo stop"
    FSR::Cmd::Sofia::Profile.restart("foo", nil).raw.should == "sofia profile foo restart"
    FSR::Cmd::Sofia::Profile.rescan("foo", nil).raw.should == "sofia profile foo rescan"
  end

  it "should allow instantiation directly, with hash options" do
    # pass nil as the socket until we get the MockSocket completed
    profile = FSR::Cmd::Sofia::Profile.new(nil, {:name => 'internal', :action => :stop}) 
    profile.raw.should == "sofia profile internal stop"
  end

end
