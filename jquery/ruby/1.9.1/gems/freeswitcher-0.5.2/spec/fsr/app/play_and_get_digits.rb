require 'spec/helper'
require "fsr/app"
FSR::App.load_application("play_and_get_digits")

describe "Testing FSR::App::PlayAndGetDigits" do
  # Utilize the [] shortcut to start a conference
  it "Send a play_and_gets_digits command, default args" do
    tmp = FSR::App::PlayAndGetDigits.new("soundfile.wav", "invalid.wav")
    tmp.sendmsg.should == "call-command: execute\nexecute-app-name: play_and_get_digits\nexecute-app-arg: 0 10 3 7000 # soundfile.wav invalid.wav fsr_read_dtmf \\d\nevent-lock:true\n\n"
  end

  it "Send a play_and_gets_digits command with array args, one arg" do
    tmp = FSR::App::PlayAndGetDigits.new("soundfile.wav", "invalid.wav", "4")
    tmp.sendmsg.should == "call-command: execute\nexecute-app-name: play_and_get_digits\nexecute-app-arg: 4 10 3 7000 # soundfile.wav invalid.wav fsr_read_dtmf \\d\nevent-lock:true\n\n"
  end

  it "Send a play_and_gets_digits command with array args, two args" do
    tmp = FSR::App::PlayAndGetDigits.new("soundfile.wav", "invalid.wav", "4", "4")
    tmp.sendmsg.should == "call-command: execute\nexecute-app-name: play_and_get_digits\nexecute-app-arg: 4 4 3 7000 # soundfile.wav invalid.wav fsr_read_dtmf \\d\nevent-lock:true\n\n"
  end

  it "Send a play_and_gets_digits command with array args, three args" do
    tmp = FSR::App::PlayAndGetDigits.new("soundfile.wav", "invalid.wav", "4", "4", "2")
    tmp.sendmsg.should == "call-command: execute\nexecute-app-name: play_and_get_digits\nexecute-app-arg: 4 4 2 7000 # soundfile.wav invalid.wav fsr_read_dtmf \\d\nevent-lock:true\n\n"
  end
  it "Send a play_and_gets_digits command with array args, four args" do
    tmp = FSR::App::PlayAndGetDigits.new("soundfile.wav", "invalid.wav", "4", "4", "2", "10000")
    tmp.sendmsg.should == "call-command: execute\nexecute-app-name: play_and_get_digits\nexecute-app-arg: 4 4 2 10000 # soundfile.wav invalid.wav fsr_read_dtmf \\d\nevent-lock:true\n\n"
  end

  it "Send a play_and_gets_digits command with array args, five args" do
    tmp = FSR::App::PlayAndGetDigits.new("soundfile.wav", "invalid.wav", "4", "4", "2", "10000", ['*'])
    tmp.sendmsg.should == "call-command: execute\nexecute-app-name: play_and_get_digits\nexecute-app-arg: 4 4 2 10000 * soundfile.wav invalid.wav fsr_read_dtmf \\d\nevent-lock:true\n\n"
  end

  it "Send a play_and_gets_digits command with array args, six args" do
    tmp = FSR::App::PlayAndGetDigits.new("soundfile.wav", "invalid.wav", "4", "4", "2", "10000", ['*'], "read_var")
    tmp.sendmsg.should == "call-command: execute\nexecute-app-name: play_and_get_digits\nexecute-app-arg: 4 4 2 10000 * soundfile.wav invalid.wav read_var \\d\nevent-lock:true\n\n"
  end

  it "Send a play_and_gets_digits command with array args, seven args" do
    tmp = FSR::App::PlayAndGetDigits.new("soundfile.wav", "invalid.wav", "4", "4", "2", "10000", ['*'], "read_var", '\w')
    tmp.sendmsg.should == "call-command: execute\nexecute-app-name: play_and_get_digits\nexecute-app-arg: 4 4 2 10000 * soundfile.wav invalid.wav read_var \\w\nevent-lock:true\n\n"
  end

  it "Send a play_and_gets_digits command with hash args, just max" do
    tmp = FSR::App::PlayAndGetDigits.new("soundfile.wav", "invalid.wav", :max => "4")
    tmp.sendmsg.should == "call-command: execute\nexecute-app-name: play_and_get_digits\nexecute-app-arg: 0 4 3 7000 # soundfile.wav invalid.wav fsr_read_dtmf \\d\nevent-lock:true\n\n"
  end

end

describe "Testing FSR::App::PlayAndGetDigits - handling of non-existant files" do

  it "Raise if files specifed absolutely aren't present" do
    lambda { FSR::App::PlayAndGetDigits.new("/path/soundfile.wav", "/path/invalid.wav") }.
      should.raise(Errno::ENOENT)
  end

  it "Not raise if files specifed absolutely aren't present" do
    file_name = File.expand_path(__FILE__)
    lambda { FSR::App::PlayAndGetDigits.new(file_name, "invalid.wav") }.
      should.not.raise(Errno::ENOENT)
  end
  
end