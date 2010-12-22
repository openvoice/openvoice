require "fsr/event_socket"
require "fsr/cmd"
module FSR
  class CommandSocket < EventSocket
    include Cmd

    def initialize(args = {})
      @server = args[:server] || "127.0.0.1"
      @port = args[:port] || "8021"
      @auth = args[:auth] || "ClueCon"
      @socket = TCPSocket.new(@server, @port)
      super(@socket)
      # Attempt to login or raise an exception
      unless login
        raise "Unable to login, check your password!"
      end
    end
    
    # login - Method to authenticate to FreeSWITCH
    def login
      #Clear buf from initial socket creation/opening
      response 
      # Send auth string to FreeSWITCH
      self << "auth #{@auth}"
      #Return response, clear buf for rest of commands
      response 
    end
  end
end
