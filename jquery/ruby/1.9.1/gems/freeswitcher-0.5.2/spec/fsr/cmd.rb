require "spec/helper"
describe "Basic FSR::Cmd module" do
  it "Aliases itself as FSC" do
    require "fsr/cmd"
    FSC.should == FSR::Cmd 
  end
end

