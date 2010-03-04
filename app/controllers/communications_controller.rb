class CommunicationsController < ApplicationController
  def index
    headers = params["session"]["headers"]
    x_voxeo_to = headers.select{ |v| v["key"] == 'x-voxeo-to' }.first["value"]
    sip_client = get_sip_client_from_header(x_voxeo_to)
    from = params["session"]["from"]["id"]
    tropo = Tropo::Generator.new do

#      say "hello, hello, welcome to zhao's communication center"
#      say :value => 'Bienvenido a centro de comunicaci\227n de Zhao', :voice => 'carmen'
#      say :value => 'Bienvenue au centre de communication de Zhao', :voice => 'florence'
                                  
      on(:event => 'continue', :next => "answer?caller_id=#{from}@#{sip_client}")

      ask( :attempts => 2,
           :bargein => true,
           :choices => { :value => "connect(connect, 1), voicemail(voicemail, 2)" },
           :name => 'main-menu',
           :say => { :value => 'To speak to Zhao, say connect or press 1. To leave a voicemail, say voicemail or press 2.' })

    end

    render :json => tropo.response
  end

  def answer
    value = params[:result][:actions][:value]
    caller_id = params[:caller_id]
    CallLog.create(:from => caller_id, :to => "you", :nature => "incoming")
    case value
      when 'connect'
        tropo = Tropo::Generator.new do
          say :value => 'connecting to zhao'
          transfer({ :to => 'tel:' + User.find(1).phone_numbers.first.number,
                     :ringRepeat => 2,
                     :timeout => 5,
                     :answerOnMedia => true,
                     #                     :on => [
                     #                             { :event => "continue", :next => '/voicemails/index?format=json' },
                     #                             { :event => "incomplete", :next => '/voicemails/index?format=json' },
                     #                             { :event => "error", :next => '/voicemails/index?format=json' },
                     #                             { :event => "hangup", :next => '/voicemails/index?format=json' },
                     #
                     #                     ],
                     #                     :from => { :id => from + "@" + sip_client,
                     #                                :name => from,
                     #                                :channel => "VOICE",
                     #                                :network => "PSTN" }
          })
        end
        render :json => tropo.response

      when 'voicemail'
        tropo = Tropo::Generator.new do
          record( :say => [:value => 'welcome to zhao\'s voicemail system, please speak after the beep'],
                  :beep => true,
          :maxTime => 30,
          :format => "audio/mp3",
          :name => "voicemail",
          :url => SERVER_URL + "/voicemails?caller_id=#{caller_id}",
          :transcriptionOutURI => SERVER_URL + "/voicemails/set_transcription&voicemail_id=1",
          :transcriptionID => '1234' )
        end

        render :json => tropo.response

    end

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
