require 'spec/helper'
require "fsr/app"
FSR::App.load_application("set")

describe "Testing FSR::App::Set" do
  # Utilize the [] shortcut to start a conference
  it "Sets a single variable" do
    set = FSR::App::Set.new("hangup_after_bridge", true)
    set.sendmsg.should == "call-command: execute\nexecute-app-name: set\nexecute-app-arg: hangup_after_bridge=true\nevent-lock:true\n\n"
  end

end
