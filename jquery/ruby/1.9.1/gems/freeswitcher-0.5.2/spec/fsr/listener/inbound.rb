require 'spec/helper'
require 'lib/fsr'
require "fsr/listener"
require "fsr/listener/inbound"
require "em-spec/bacon"
EM.spec_backend = EventMachine::Spec::Bacon

# Bare class to use for testing
class InboundListener < FSR::Listener::Inbound
  attr_accessor :custom_event

  # Stub error? out, do this to force session establishment
  # Alternatively, you can 
  #   InboundListener.new.authorize_and_register_for_events
  # explicitly
  def error?
    false
  end

  def before_session
    add_event(:CUSTOM) { |e| @custom_event = e }
  end

  def initialize(*args)
    super(*args)
    @test_event = nil
  end

  def on_event(event)
    recvd_event << event
  end

  def recvd_event
    @recvd_event ||= []
  end
end

class InboundListener2 < InboundListener
  attr_accessor :test_event
  def before_session
    add_event(:TEST_EVENT) { |e| @test_event = e}
  end
end

class InboundListener3 < InboundListener2
  def before_session
    add_event(:CUSTOM, "fifo::info") { |e| @custom_event = e }
  end
end
describe "Testing FSR::Listener::Inbound" do
  it "defines #post_init" do
    FSR::Listener::Inbound.method_defined?(:post_init).should == true
  end

  it "adds and deletes hooks" do
    FSL::Inbound.add_event_hook(:CHANNEL_CREATE) {|event| puts event.inspect }
    FSL::Inbound::HOOKS.size.should == 1
    FSL::Inbound.del_event_hook(:CHANNEL_CREATE)
    FSL::Inbound::HOOKS.size.should == 0
  end
end

EM.describe InboundListener do
  before do
    @listener = InboundListener.new(1234, {:auth => 'SecretPassword'})
    @listener2 = InboundListener2.new(1234, {:auth => 'SecretPassword'})
  end

  should "be able to receive an event and call the on_event callback method" do
    @listener.receive_data("Content-Length: 22\nContent-Type: text/event-plain\n\nEvent-Name: test_event\n\n")
    @listener.recvd_event.first.content[:event_name].should.equal "test_event"
    done
  end

  should "be able to add custom event hooks on instances in the pre_session (before_session)" do
    @listener.receive_data("Content-Length: 18\nContent-Type: text/event-plain\n\nEvent-Name: CUSTOM\n\n")
    @listener.custom_event.should.not.be.nil
    @listener.custom_event.content[:event_name].should == "CUSTOM"
    @listener.custom_event.should.equal @listener.recvd_event.first
    @listener2.receive_data("Content-Length: 22\nContent-Type: text/event-plain\n\nEvent-Name: TEST_EVENT\n\n")
    @listener2.test_event.content[:event_name].should.equal "TEST_EVENT"
    done
  end

  should "be able to add custom event hooks with sub events" do
    listener = InboundListener3.new(1234, {:auth => 'SecretPassword'})
    @listener.receive_data("Content-Length: 22\nContent-Type: text/event-plain\n\nEvent-Name: CUSTOM\n\n")
    @listener.custom_event.should.equal @listener.recvd_event.first
    done
  end

  should "be able to add custom event hooks on classes, before instantiation" do
    FSL::Inbound.add_event_hook(:HANGUP_EVENT) { |instance, event| instance.test_event = event }
    listener = InboundListener2.new(1234, {:auth => 'SecretPassword'})
    listener.receive_data("Content-Length: 24\nContent-Type: text/event-plain\n\nEvent-Name: HANGUP_EVENT\n\n")
    listener.test_event.content[:event_name].should.equal "HANGUP_EVENT"
    done
  end

  should "be able to add custom event hooks on classes, after instantiation" do
    listener = InboundListener2.new(1234, {:auth => 'SecretPassword'})
    FSL::Inbound.add_event_hook(:HANGUP_EVENT) { |instance, event| instance.test_event = event }
    listener.receive_data("Content-Length: 24\nContent-Type: text/event-plain\n\nEvent-Name: HANGUP_EVENT\n\n")
    listener.test_event.content[:event_name].should.equal "HANGUP_EVENT"
    done
  end

  should "be able to change Freeswitch auth" do
    @listener.auth.should.equal 'SecretPassword'
    done
  end
end
