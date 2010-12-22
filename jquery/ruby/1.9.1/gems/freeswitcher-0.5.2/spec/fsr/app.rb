require "spec/helper"
describe "Basic FSR::App module" do
  it "Aliases itself as FSA" do
    require "fsr/app"
    FSA.should == FSR::App 
  end


end

