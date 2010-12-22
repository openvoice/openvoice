require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "TropoProvisioning" do
  before(:all) do
    @app_details = { :voiceUrl     => 'http://mydomain.com/voice_script.rb',
                     :partition    => 'staging',
                     :messagingUrl => 'http://mydomain.com/message_script.rb',
                     :platform     => 'scripting' }
    @tp = TropoProvisioning.new('jsgoecke', 'test123')
  end
  
  after(:all) do
    
  end
  
  it "should create an application" do
    result = @tp.create_application(@app_details.merge!({ :name => 'Live API Test' }))
    result.href.should =~ /^http:\/\/api.tropo.com\/provisioning\/applications\/\d{1,7}$/
    result.application_id.should =~ /\d{1,7}/
    APPLICATION_ID = result.application_id
  end
  
  it "should get a list of exchanges" do
    exchanges = @tp.exchanges
    exchanges[0].city.should == 'Houston'
  end
  
  it "should add a phone, IM and token address to the application" do  
    result = @tp.create_address(APPLICATION_ID, { :type => 'number', :prefix => @tp.exchanges[0].prefix })
    result.href.should =~ /http:\/\/api.tropo.com\/provisioning\/applications\/\d{1,7}\/addresses\/number\/\d{1,20}/
    
    result = @tp.create_address(APPLICATION_ID, { :type => 'jabber', :username => "liveapitest#{rand(100000).to_s}@bot.im" } )
    result.href.should =~ /http:\/\/api.tropo.com\/provisioning\/applications\/\d{1,7}\/addresses\/jabber\/\w{10,16}@bot.im/
    
    result = @tp.create_address(APPLICATION_ID, { :type => 'token', :channel => 'voice' } )
    result.href.should =~ /http:\/\/api.tropo.com\/provisioning\/applications\/\d{1,7}\/addresses\/token\/\w{88}/
  end
  
  it "should update the application" do
    # First, get the application in question
    app_data = @tp.application(APPLICATION_ID)
    app_data['name'] = 'Live API Test Update'
    result = @tp.update_application(APPLICATION_ID, app_data)
    result.href.should =~ /^http:\/\/api.tropo.com\/provisioning\/applications\/\d{1,7}$/
  end
  
  it "should move a address to a new application and then back" do
    new_app = @tp.create_application(@app_details.merge!({ :name => 'Live API Test New' }))
    new_app.href.should =~ /^http:\/\/api.tropo.com\/provisioning\/applications\/\d{1,7}$/
    new_address = @tp.create_address(new_app.application_id, { :type => 'number', :prefix => @tp.exchanges[0]['prefix'] })
    
    result = @tp.move_address({ :from    => APPLICATION_ID,
                                :to      => new_app,
                                :address => new_address.address })
    result.should == nil
    
    result = @tp.move_address({ :from    => new_app,
                                :to      => APPLICATION_ID,
                                :address => new_address.address })
    result.should == nil    
  end
  
  # it "should delete the addresses of an application" do
  #   addresses = @tp.addresses(APPLICATION_ID)
  #   addresses.each do |address|
  #     result = @tp.delete_address(APPLICATION_ID, address['number']) if address['number']
  #     result.message.should == 'delete successful'
  #     result = @tp.delete_address(APPLICATION_ID, address['username']) if address['username']
  #     result.message.should == 'delete successful'
  #   end
  # end
  # 
  # it "should delete an application" do
  #   result = @tp.delete_application(APPLICATION_ID)
  #   result.message.should == 'delete successful'
  # end
end