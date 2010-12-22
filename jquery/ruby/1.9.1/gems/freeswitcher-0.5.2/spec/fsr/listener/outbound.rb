require 'spec/helper'
require 'lib/fsr'
require "fsr/listener"
require "fsr/listener/inbound"
require "fsr/listener/outbound"
require "em-spec/bacon"
EM.spec_backend = EventMachine::Spec::Bacon
# Bare class to use for testing
class MyListener < FSR::Listener::Outbound
  attr_accessor :recvd_reply, :state_machine_test, :state_machine_test2
  attr_reader :queue

  def session_initiated
  end

  def send_data(data)
    sent_data << data
  end

  def sent_data
    @sent_data ||= ''
  end

  def receive_reply(reply)
    recvd_reply << reply
  end

  def recvd_reply
    @recvd_reply ||= []
  end

  def do_something(&block)
    @queue.unshift block if block_given? 
  end

  def set(var, value, &block)
     @queue.unshift(block_given? ? block : lambda {})
  end

  def test_state_machine
    @state_machine_test = nil
    do_something do 
      @state_machine_test = "one"

      do_something do
        @state_machine_test = "two"

        do_something do
          @state_machine_test = "three"
        end
      end
    end
  end

  def test_state_machine_without_blocks
    answer
    set("test", "test1")
    set("another_one", "bites_the_dust")
  end

end

# Begin testing MyListener
EM.describe MyListener do

  before do
    @listener = MyListener.new(nil)
  end

  should "send connect to freeswitch upon a new connection" do
    @listener.receive_data("Content-Length: 0\nCaller-Caller-ID-Number: 8675309\n\n")
    @listener.sent_data.should.equal "connect\n\n"
    done
  end

  should "be able to receive a connection and establish a session " do
    @listener.receive_data("Content-Length: 0\nTest: Testing\n\n")
    @listener.session.class.should.equal FSR::Listener::HeaderAndContentResponse
    done
  end

  should "be able to read FreeSWITCH channel variables through session" do
    @listener.receive_data("Content-Length: 0\nCaller-Caller-ID-Number: 8675309\n\n")
    @listener.session.headers[:caller_caller_id_number].should.equal "8675309"
    done
  end

  should "be able to receive and process a response if not sent in one transmission" do
    @listener.receive_data("Content-Length: ")
    @listener.receive_data("0\nCaller-Caller-")
    @listener.receive_data("ID-Number: 8675309\n\n")
    @listener.session.headers[:caller_caller_id_number].should.equal "8675309"
    done
  end

  should "be able to dispatch our receive_reply callback method after a session is already established" do
    # This should establish the session
    @listener.receive_data("Content-Length: 0\nTest-Data: foo\n\n")

    # This should be a response, not a session
    @listener.receive_data("Content-Length: 0\nTest-Reply: bar\n\n")

    @listener.session.headers[:test_data].should.equal 'foo'
    @listener.recvd_reply.first.headers[:test_reply].should.equal 'bar'
    done
  end

  should "use procs to 'fake' I/O blocking and wait for a response before calling the next proc" do
    @listener.receive_data("Content-Length: 0\nEstablished-Session: session\n\n")
    @listener.test_state_machine
    @listener.state_machine_test.should.equal nil
    @listener.receive_data("Content-Length: 3\n\nOk\n\n")
    @listener.state_machine_test.should.equal "one"
    @listener.receive_data("Content-Length: 3\n\nOk\n\n")
    @listener.state_machine_test.should.equal "two"
    @listener.receive_data("Content-Length: 3\n\nOk\n\n")
    @listener.state_machine_test.should.equal "three"
    done
  end

  should "use implicit blocks to 'fake' I/O blocking and wait for a response before calling the next implicit block" do
    @listener.receive_data("Content-Length: 0\nEstablished-Session: session\n\n")
    @listener.test_state_machine_without_blocks
    @listener.queue.size.should.equal 3
    @listener.receive_data("Content-Length: 3\n\nOk\n\n")
    @listener.queue.size.should.equal 2
    @listener.receive_data("Content-Length: 3\n\nOk\n\n")
    @listener.queue.size.should.equal 1
    @listener.receive_data("Content-Length: 3\n\nOk\n\n")
    @listener.queue.empty?.should.equal true
    done
  end


  should "be able to update an existing session" do
    @listener.receive_data("Content-Length: 0\nUnique-ID: abcd-1234-efgh-5678\n\n")
    @listener.session.headers[:unique_id].should.equal "abcd-1234-efgh-5678"
    @listener.session.headers[:test_var].should.equal nil
    @listener.update_session
    @listener.receive_data("Content-Length: 74\n\nEvent-Name: CHANNEL_DATA\nUnique-ID: abcd-1234-efgh-5678\nTest-Var: foobar\n\n")
    @listener.session.headers[:test_var].should.equal "foobar"
    done
  end

end
