class CommunicationsController < ApplicationController
  def index
    tropo = Tropo::Generator.new do

      say "hello, hello, hello, welcome to zhao's communication center, please wait while your call is transferred"
#      say :value => 'Bienvenido a centro de comunicaci—n de Zhao', :voice => 'carman'
      transfer({ :to => 'tel:' + User.find(1).phone_numbers.first.number })
    end
    
    render :json => tropo.response
  end
end
