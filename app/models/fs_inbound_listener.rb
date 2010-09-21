#class FSInboundListener < FSR::Listener::Inbound
#  def on_event(event)
#    # Be sure to check out the content of `event`. It has all the good stuff.
#    FSR::Log.info "+++++++++++++++++++Got event: #{event.content[:event_name]}"
#  end
#
#  # You can add a hook for a certain event:
#  add_event_hook :CHANNEL_HANGUP do
#    FSR::Log.info "Channel hangup!"
#
#    # It is instance_eval'ed, so you can use your instance methods etc:
#    do_something
#  end
#
#  def do_something
#    FSR::Log.info "++++++++++++++++++hanging up....................."
#  end
#end

#FSR.start FSInboundListener, :host => ENV["FS_HOST"], :port => ENV["FS_PORT"], :auth => ENV['FS_PASSWORD']
#FSR.start_ies! FSInboundListener, :host => ENV["FS_HOST"], :port => ENV["FS_PORT"], :auth => ENV['FS_PASSWORD']

