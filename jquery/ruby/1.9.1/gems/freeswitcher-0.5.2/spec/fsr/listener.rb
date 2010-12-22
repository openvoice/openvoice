require "spec/helper"
require "fsr/listener"
describe "Basic FSR::Listener module" do
  it "Aliases itself as FSL" do
    FSL.should == FSR::Listener 
  end

  it "Defines #receive_data" do
    FSR::Listener.method_defined?(:receive_data).should == true
  end
end

