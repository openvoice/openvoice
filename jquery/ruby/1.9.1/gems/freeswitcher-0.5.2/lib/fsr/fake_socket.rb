## Fake socket used for mock testing ##
#
require 'stringio'

module FSR
  class FakeSocket
    def initialize(remote_host, remote_port)
      @remote_host, @remote_port = remote_host, remote_port

      @input = StringIO.new('')
      @buffer = []
    end

    def hostname
      'localhost'
    end

    def address
      '127.0.0.1'
    end

    def eof?
      @input.eof?
    end
    alias closed? eof?

    def close
    end

    def print(*args)
      @buffer << args.join
    end

    def read(len)
      @input.read(len)
    end

    def fake_input
      @input
    end

    def fake_buffer
      @buffer
    end
  end
end

require 'bacon'
Bacon.summary_at_exit

describe FSR::FakeSocket do
  it 'can be initialized' do
    @socket = FSR::FakeSocket.new('google.com', 80)
    @socket.should.not.be.nil
  end

  it 'can be filled with input which is then read' do
    @socket.fake_input.write('foobar')
    @socket.fake_input.pos = 0
    @socket.read(6).should == 'foobar'
    @socket.read(1).should == nil
  end

  it 'can receive input' do
    @socket.print('foo')
    @socket.fake_buffer.should == ['foo']
  end
end
