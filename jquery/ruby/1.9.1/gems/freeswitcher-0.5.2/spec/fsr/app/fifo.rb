require 'spec/helper'
require "fsr/app"
FSR::App.load_application("fifo")

describe "Testing FSR::App::Fifo" do
  # Utilize the [] shortcut to start a conference
  it "Puts a call into a queue, with #new" do
    fifo = FSR::App::Fifo.new("myqueue", "in")
    fifo.raw.should == "fifo(myqueue in)"
  end

  it "Puts a call into a queue, with <<" do
    fifo = FSR::App::Fifo << "myqueue"
    fifo.raw.should == "fifo(myqueue in)"
  end

  it "Adds a consumer to a queue, with #new" do
    fifo = FSR::App::Fifo.new("myqueue", "out")
    fifo.raw.should == "fifo(myqueue out nowait)"
    fifo = FSR::App::Fifo.new("myqueue", "out", :wait => true)
    fifo.raw.should == "fifo(myqueue out wait)"
  end
  
  it "Adds a consumer to a queue, with >>" do
    fifo = FSR::App::Fifo >> "myqueue"
    fifo.raw.should == "fifo(myqueue out wait)"
  end

end
