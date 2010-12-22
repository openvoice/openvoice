require 'spec/helper'
require "fsr/cmd"
FSR::Cmd.load_command("enum")

describe "Testing FSR::Cmd::Enum" do
  ## Enum  ##
  # Interface to enum 
  it "FSR::Cmd::Enum should send enum <did>" do
    cmd = FSR::Cmd::Enum.new(nil, "13012221111")
    cmd.raw.should == "enum 13012221111"
  end

  it "FSR::Cmd::Enum should return nil if response is 'No Match!'" do
    cmd = FSR::Cmd::Enum.new(nil, "13012221111")
    response={"Content-Type"=>"api/response", "Content-Length"=>"366", "body"=>"Offered Routes:\nOrder\tPref\tService   \tRoute\n==============================================================================\n5\t10\tE2U+h323  \topal/h323:+13012221111@128.121.41.89:1720\n\nSupported Routes:\nOrder\tPref\tService   \tRoute\n==============================================================================\n5\t10\tE2U+h323  \topal/h323:+13012221111@128.121.41.89:1720"}
    cmd.parse(response).route == "opal/h323:+13012221111@128.121.41.89:1720"
  end

end
