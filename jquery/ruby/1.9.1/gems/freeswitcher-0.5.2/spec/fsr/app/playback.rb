require 'spec/helper'
require "fsr/app"
FSR::App.load_application("playback")

describe "Testing FSR::App::Playback" do
  it "Plays a file or stream" do
    playback = FSR::App::Playback.new("shout://scfire-ntc-aa01.stream.aol.com/stream/1035")
    playback.sendmsg.should == "call-command: execute\nexecute-app-name: playback\nexecute-app-arg: shout://scfire-ntc-aa01.stream.aol.com/stream/1035\nevent-lock:true\n\n"
  end

end

describe "Testing FSR::App::Playback - handling of non-existant files" do

  it "Raise if files specifed absolutely aren't present" do
    lambda { FSR::App::Playback.new("/path/non-existing.wav") }.
      should.raise(Errno::ENOENT)
  end

  it "Not raise if not an absolute file" do
    file_name = File.expand_path(__FILE__)
    lambda { FSR::App::Playback.new("shout://scfire-ntc-aa01.stream.aol.com/stream/1035") }.
      should.not.raise(Errno::ENOENT)
  end

end