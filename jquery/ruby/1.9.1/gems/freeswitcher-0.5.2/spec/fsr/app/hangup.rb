require 'spec/helper'
require "fsr/app"
FSR::App.load_application("hangup")

describe "Testing FSR::App::Hangup" do
  it "Hangs up the channel" do
    hangup = FSR::App::Hangup.new
    hangup.sendmsg.should == "call-command: execute\nexecute-app-name: hangup\nexecute-app-arg: \n\n"
  end

  it "Hangs up the channel using a hangup cause" do
    hangup = FSR::App::Hangup.new("USER_BUSY")
    hangup.sendmsg.should == "call-command: execute\nexecute-app-name: hangup\nexecute-app-arg: USER_BUSY\n\n"
  end

end
