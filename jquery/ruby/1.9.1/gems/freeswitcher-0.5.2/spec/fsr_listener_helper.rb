require File.join(File.expand_path("../", __FILE__), "../lib/fsr")
require FSR::ROOT/".."/:spec/:helper
require FSR::ROOT/:fsr/:listener/:outbound
require "em-spec/bacon"
EM.spec_backend = EventMachine::Spec::Bacon
require "fileutils"


# Shared contexts to make describing listener behavior easier
shared :fsr_listener do
  def outbound_socket(listener, from, opts = {})
    FSR::Log.outputters = Log4r::FileOutputter.new('spec', :filename => ($spec_log = "/tmp/fsr#{Time.now.to_i}_spec.log"), :level => Log4r::DEBUG)
    FSR::Log.info "Spec Time #{Time.now} file: #{$spec_log}"
    listener.receive_data("Content-Length: 0\nCaller-Caller-ID-Number: #{from}#{opts ? "\n" + opts.map{|k,v| "#{k}: #{v}" }.join("\n") : ""}\n\n")
    yield
  ensure
    if (spec = Pathname($spec_log)).file?
      puts "Socket Complete: Log Follows \n#{spec.read}"
      Pathname($spec_log).delete 
    end
  end
end
