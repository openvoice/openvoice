class CommunicationsController < ApplicationController
  def index
    headers = params["session"]["headers"]
    x_voxeo_to = headers.select{ |v| v["key"] == 'x-voxeo-to' }.first["value"]
    sip_client = get_sip_client_from_header(x_voxeo_to)
    from = params["session"]["from"]["id"]
    tropo = Tropo::Generator.new do
      say "hello, hello, hello, welcome to zhao's communication center, please wait while your call is transferred"
      say :value => 'Bienvenido a centro de comunicaci—n de Zhao', :voice => 'carmen'
      transfer({ :to => 'tel:' + User.find(1).phone_numbers.first.number,
                 :ringRepeat => 2,
                 :timeout => 5,
                 :answerOnMedia => true,
                 :on => [
                         { :event => "continue", :next => '/voicemails/index?format=json' },
                         { :event => "incomplete", :next => '/voicemails/index?format=json' },
                         { :event => "error", :next => '/voicemails/index?format=json' },
                         { :event => "hangup", :next => '/voicemails/index?format=json' },

                 ],
                 :from => { :id => from + "@" + sip_client,
                            :name => from,
                            :channel => "VOICE",
                            :network => "PSTN" } })
    end

    render :json => tropo.response
  end

  private

  def get_sip_client_from_header(header)
    if header =~ /^<sip:990.*$/                   # SKYPE
      "SKYPE"
    elsif header =~ /^.*<sip:1999.*$/             # SIP
      "SIP"
    elsif header =~ /^<sip:883.*$/                # iNUM
      "INUM"
    elsif header =~ /^.*<sip:|[1-9][0-9][0-9].*$/ # PSTN
      "PSTN"
    else
      "OTHER"
    end
  end
end
