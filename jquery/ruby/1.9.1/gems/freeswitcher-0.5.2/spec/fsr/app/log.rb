require 'spec/helper'
require "fsr/app"
FSR::App.load_application("log")

describe "Testing FSR::App::Log" do
  it "Logs to the console" do
    log = FSR::App::Log.new(1, "This is a test! :-)")
    log.sendmsg.should == "call-command: execute\nexecute-app-name: log\nexecute-app-arg: 1 This is a test! :-)\nevent-lock:true\n\n"
  end

end
