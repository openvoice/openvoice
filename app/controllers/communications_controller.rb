class CommunicationsController < ApplicationController
  def index
    headers = params["session"]["headers"]
    x_voxeo_to = headers["x-voxeo-to"]
    sip_client = get_sip_client_from_header(x_voxeo_to)
    from = params["session"]["from"]["id"]
    tropo = Tropo::Generator.new do
      say "hello, welcome to zhao's open voice communication center"
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
          transfer({ # TODO where to send the incoming calls?  ring all phones?
                     :to => 'zlu-100@pbxes.org',
                     :ringRepeat => 3,
                     :timeout => 30,
                     :answerOnMedia => true,
                     # TODO figure out the correct caller_id when not pstn
                     :from => "14085059096"
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
                  :url => SERVER_URL + "/voicemails/create?caller_id=#{caller_id}")#,
#          :transcriptionOutURI => SERVER_URL + "/voicemails/set_transcription&voicemail_id=1",
#          :transcriptionID => '1234' )
        end
        render :json => tropo.response

      else
        tropo = Tropo::Generator.new do
          say "Please try again with keypad"
        end
        render :json => tropo.response
      end
  end

  private

  def get_sip_client_from_header(header)
    if header =~ /^<sip:990.*$/
      "SKYPE"
    elsif header =~ /^.*<sip:1999.*$/
      "SIP"
    elsif header =~ /^<sip:883.*$/
      "INUM"
    elsif header =~ /^.*<sip:|[1-9][0-9][0-9].*$/
      "PSTN"
    else
      "OTHER"
    end
  end

end
