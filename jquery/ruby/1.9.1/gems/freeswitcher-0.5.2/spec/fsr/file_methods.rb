require "spec/helper"
require "fsr/file_methods"

describe "Basic FSR::App::FileMethods module" do

  before do
    @testee = Class.new do
      include ::FSR::App::FileMethods
    end.new
    
  end

  it "should have a test_files method" do
    @testee.test_files("bla").should.equal true
  end

  it "should only test files with an absolute path" do
    lambda { @testee.test_files("/path/file") }.
      should.raise(Errno::ENOENT)
  end

  it "should handle multiple files" do
    @testee.test_files("bla.wav", "fasel.wav").should.equal true
  end

  it "should handle mixed absolute and relative files" do
    lambda { @testee.test_files("some_file.wav", "/path/file") }.
      should.raise(Errno::ENOENT)
  end

  it "should not raise if file is present" do
    file_name = File.expand_path(__FILE__)
    lambda { @testee.test_files(file_name) }.
      should.not.raise
  end
end
