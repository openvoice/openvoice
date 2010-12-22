#!/usr/bin/env ruby

require 'pp'
require File.join(File.dirname(__FILE__), "..", 'lib', 'fsr')
$stdout.flush
require "fsr/listener/inbound"


class IesDemo < FSR::Listener::Inbound

  def on_event(event)
    pp event.headers
    pp event.content[:event_name].to_s
  end

end

FSR.start_ies!(IesDemo, :host => "pip", :port => 8021, :auth => "ClueCon")
