require 'spec/helper'
require "fsr/app"
FSR::App.load_application("fs_sleep")

describe "Testing FSR::App::FsSleep" do

  it "should put FreeSWITCH leg to sleep for 7000 miliseconds" do
    fs_sleep = FSR::App::FSSleep.new(7000)
    fs_sleep.sendmsg.should == "call-command: execute\nexecute-app-name: sleep\nexecute-app-arg: 7000\n\n"
  end

end
