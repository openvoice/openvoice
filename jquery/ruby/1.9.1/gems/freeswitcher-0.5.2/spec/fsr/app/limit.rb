require 'spec/helper'
require "fsr/app"
FSR::App.load_application("limit")

describe "Testing FSR::App::Limit" do
  ## Calls ##
  # Interface to calls
  it "FSR::App::Limit should send proper limit command only passing an id" do
    limit = FSR::App::Limit.new("fsr_caller")
    limit.raw.should == "limit($${domain} fsr_caller 5)"
    limit.sendmsg.should == "call-command: execute\nexecute-app-name: limit\nexecute-app-arg: $${domain} fsr_caller 5\n\n"
  end

  it "FSR::App::Limit should send proper limit command passing id and realm" do
    limit = FSR::App::Limit.new("fsr_caller", "foodomain")
    limit.raw.should == "limit(foodomain fsr_caller 5)"
    limit.sendmsg.should == "call-command: execute\nexecute-app-name: limit\nexecute-app-arg: foodomain fsr_caller 5\n\n"
  end

  it "FSR::App::Limit should send proper limit command passing id, realm, and limit" do
    limit = FSR::App::Limit.new("fsr_caller", "foodomain", 10)
    limit.raw.should == "limit(foodomain fsr_caller 10)"
    limit.sendmsg.should == "call-command: execute\nexecute-app-name: limit\nexecute-app-arg: foodomain fsr_caller 10\n\n"
  end

end
