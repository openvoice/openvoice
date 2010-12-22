module FSR
  class EventSocket
    attr_reader :socket

    def initialize(socket)
      @socket = socket
    end

    # Send a command and return response
    def say(cmd)
      @socket.send("#{cmd}\n\n",0)
      response
    end

    # Send a command, do not return response
    def <<(cmd)
      @socket.send("#{cmd}\n\n",0)
    end

    # Grab result from command and create a hash, simple but works.
    def get_header_and_body
      headers, body = {}, ""
      until line = @socket.gets and line.chomp.empty?
        if (kv = line.chomp.split(/:\s+/,2)).size == 2
          headers.store *kv
        end
      end
      if (content_length = headers["Content-Length"].to_i) > 0
        Log.debug "content_length is #{content_length}, grabbing from socket"
        body << @socket.read(content_length)
      end
      headers.merge("body" => body.strip)
    end

    # Scrub result into a hash
    def response
      get_header_and_body
    end

  end
end
