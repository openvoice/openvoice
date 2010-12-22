require 'spec/helper'
require "fsr/app"
FSR::App.load_application("bridge")

describe "Testing FSR::App::Bridge" do
  describe "with a single endpoint" do
    before do
      @bridge = FSR::App::Bridge.new("user/bougyman")
    end

    # Utilize the [] shortcut to start a conference
    it "bridges a call, for FSR::Listener::Inbound" do
      @bridge.raw.should == "bridge({}user/bougyman)"
    end

    it "bridges a call, for FSR::Listener::Outbound" do
      @bridge.sendmsg.should == "call-command: execute\nexecute-app-name: bridge\nexecute-app-arg: user/bougyman\n\n"
    end
  end

  describe "with multiple simultaneous endpoints" do
    before do
      @bridge = FSR::App::Bridge.new("user/bougyman", "user/coltrane")
    end

    it "bridges a call, for FSR::Listener::Inbound" do
      @bridge.raw.should == "bridge({}user/bougyman,user/coltrane)"
    end

    it "bridges a call, for FSR::Listener::Outbound" do
      @bridge.sendmsg.should == "call-command: execute\nexecute-app-name: bridge\nexecute-app-arg: user/bougyman,user/coltrane\n\n"
    end
  end
  
  describe "with multiple sequential endpoints" do
    before do
      @bridge = FSR::App::Bridge.new("user/bougyman", "user/coltrane", :sequential => true)
    end

    it "bridges a call, for FSR::Listener::Inbound" do
      @bridge.raw.should == "bridge({}user/bougyman|user/coltrane)"
    end

    it "bridges a call, for FSR::Listener::Outbound" do
      @bridge.sendmsg.should == "call-command: execute\nexecute-app-name: bridge\nexecute-app-arg: user/bougyman|user/coltrane\n\n"
    end
  end
end
