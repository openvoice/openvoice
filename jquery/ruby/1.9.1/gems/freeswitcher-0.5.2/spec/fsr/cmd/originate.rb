require 'spec/helper'
require "fsr/cmd"
FSR::Cmd.load_command("originate")

describe "Testing FSR::Cmd::Originate" do
  # Invalid originates
  it "Must be passed an argument hash" do
    lambda { FSR::Cmd::Originate.new(nil, :endpoint) }.should.raise(ArgumentError).
      message.should.match(/args \(Passed: <<<.*?>>>\) must be a hash/)
  end

  it "Should require args[:target_options] to be a hash" do
    lambda { FSR::Cmd::Originate.new(nil, :endpoint => "4000", :target => "user/bougyman", :target_options => 1) }.should.raise(ArgumentError).
      message.should.match(/args\[:target_options\] \(Passed: <<<.*?>>>\) must be a hash/)
  end

  it "Can not originate without a target" do
    lambda { FSR::Cmd::Originate.new(nil, :endpoint => "4000") }.should.raise(ArgumentError).
      message.should.match(/Cannot originate without a :target set/)
  end

  it "Can not originate without an endpoint" do
    lambda { FSR::Cmd::Originate.new(nil, :target => "4000") }.should.raise(ArgumentError).
      message.should.match(/Cannot originate without an :endpoint set/)
  end

  # Originate to an extension
  it "Originates calls to extensions" do
    originate = FSR::Cmd::Originate.new(nil, :target => "user/bougyman", :endpoint => "4000")
    originate.raw.should == "originate {ignore_early_media=true,originate_timeout=30,origination_caller_id_name=FSR,origination_caller_id_number=8675309}user/bougyman 4000"
  end

  # Different options choices
  it "Honors timeout in :timeout option" do
    originate = FSR::Cmd::Originate.new(nil, :target => "user/bougyman", :timeout => 10, :endpoint => "4000")
    originate.raw.should == "originate {ignore_early_media=true,originate_timeout=10,origination_caller_id_name=FSR,origination_caller_id_number=8675309}user/bougyman 4000"
  end

  it "Honors timeout in :target_options[timeout] option" do
    originate = FSR::Cmd::Originate.new(nil, :target => "user/bougyman", :target_options => {:timeout => 10}, :endpoint => "4000")
    originate.raw.should == "originate {ignore_early_media=true,originate_timeout=10,origination_caller_id_name=FSR,origination_caller_id_number=8675309}user/bougyman 4000"
  end

end
