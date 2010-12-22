require 'spec/helper'
require "fsr/app"
FSR::App.load_application("bind_meta_app")

describe "Testing FSR::App::BindMetaApp" do
  it "binds a meta app" do
    meta_app = FSR::App::BindMetaApp.new :key => 1, :listen_to => "a",
      :respond_on => "s", :application => "hangup"
    meta_app.sendmsg.should == "call-command: execute\nexecute-app-name: bind_meta_app\nexecute-app-arg: 1 a s hangup\n\n"
  end

  it "binds a meta app with parameters" do
    meta_app = FSR::App::BindMetaApp.new :key => 1, :listen_to => "a",
      :respond_on => "s", :application => "execute_extension",
      :parameters => "dx XML features"
    meta_app.sendmsg.should == "call-command: execute\nexecute-app-name: bind_meta_app\nexecute-app-arg: 1 a s execute_extension::dx XML features\n\n"
  end
end
