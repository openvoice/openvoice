class CommunicationsController < ApplicationController
  def index
    headers = params["session"]["headers"]
    x_voxeo_to = headers.select{ |v| v["key"] == 'x-voxeo-to' }.first["value"]
    sip_client = get_sip_client_from_header(x_voxeo_to)
    from = params["session"]["from"]["id"]
    tropo = Tropo::Generator.new do
      say "hello, hello, hello, welcome to zhao's communication center, please wait while your call is transferred"
#      say :value => 'Bienvenido a centro de comunicaci—n de Zhao', :voice => 'carman'
      transfer({ :to => 'tel:' + User.find(1).phone_numbers.first.number,
                 :from => { :id => from + "@" + sip_client,
                            :nme => from,
                            :channel => "VOICE",
                            :network => "PSTN" } })
    end

    render :json => tropo.response
  end

  private

  def get_sip_client_from_header(header)
    p '+++++++++++++++++++'
    p header
    p '+++++++++++++++++++'
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
