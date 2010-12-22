#!/usr/bin/env ruby

require 'pp'
require File.join(File.dirname(__FILE__), "..", 'lib', 'fsr')
$stdout.flush
require "fsr/listener/inbound"

# EXAMPLE 1 
# This adds a hook on CHANNEL_CREATE events. You can also create a method to handle the event you're after. See the next example
FSL::Inbound.add_event_hook(:CHANNEL_CREATE) {|event| FSR::Log.info "*** [#{event.content[:unique_id]}] Channel created - greetings from the hook!" }

# EXAMPLE 2
# Define a method to handle CHANNEL_HANGUP events.
def custom_channel_hangup_handler(event)
  FSR::Log.info "*** [#{event.content[:unique_id]}] Channel hangup. The event:"
  pp event
end

# This adds a hook for EXAMPLE 2
FSL::Inbound.add_event_hook(:CHANNEL_HANGUP) {|event| custom_channel_hangup_handler(event) }


# Start FSR Inbound Listener
FSR.start_ies!(FSL::Inbound, :host => "localhost", :port => 8021)

