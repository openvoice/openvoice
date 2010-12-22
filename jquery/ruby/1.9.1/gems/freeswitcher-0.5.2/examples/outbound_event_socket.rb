#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__), "..", 'lib', 'fsr')
require "fsr/listener/outbound"
$stdout.flush

class OutboundDemo < FSR::Listener::Outbound

  def session_initiated
    exten = @session.headers[:caller_caller_id_number]
    FSR::Log.info "*** Answering incoming call from #{exten}"

    answer do
      FSR::Log.info "***Reading DTMF from #{exten}"
      #######################################################
      ## NOTE YOU MUST MAKE SURE YOU PASS A VALID WAV FILE ##
      #######################################################
      read("/usr/local/freeswitch/sounds/music/8000/sweet.wav", 4, 10, "input", 7000) do |read_var|
          FSR::Log.info "***Success, grabbed #{read_var.to_s.strip} from #{exten}"
          # Tell the caller what they entered
          # If you have mod_flite installed you should hear speech
          speak("Got the DTMF of: #{read_var.to_s.strip}") { hangup }
      end
    end

    def receive_reply(reply)
      FSR::Log.info "Received #{reply.inspect}"
    end

  end

end

FSR.start_oes! OutboundDemo, :port => 8084, :host => "127.0.0.1"
