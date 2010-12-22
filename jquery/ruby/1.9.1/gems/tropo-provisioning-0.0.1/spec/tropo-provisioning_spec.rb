require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

# These tests are all local unit tests
FakeWeb.allow_net_connect = false

describe "TropoProvisioning" do
  before(:all) do
    @applications = [ { "voiceUrl"    => "http://webhosting.voxeo.net/1234/www/simple.js", 
                        "name"         => "API Test", 
                        "href"         => "http://api.tropo.com/v1/applications/108000", 
                        "partition"    => "staging", 
                        "platform"     => "scripting" }, 
                      { "voiceUrl"    => "http://hosting.tropo.com/1234/www/simon.rb", 
                        "name"         => "Simon Game", 
                        "href"         => "http://api.tropo.com/v1/applications/105838", 
                        "partition"    => "staging", 
                        "messagingUrl" => "http://hosting.tropo.com/1234/www/simon.rb", 
                        "platform"     => "scripting" },
                      { "voiceUrl"    => "http://webhosting.voxeo.net/1234/www/simple.js", 
                        "name"         => "Foobar", 
                        "href"         => "http://api.tropo.com/v1/applications/108002", 
                        "partition"    => "staging", 
                        "platform"     => "scripting" } ]
    
    @addresses = [ { "region" => "I-US", 
                     "city"     => "iNum US", 
                     "number"   => "883510001812716", 
                     "href"     => "http://api.tropo.com/v1/applications/108000/addresses/number/883510001812716", 
                     "prefix"   => "008", 
                     "type"     => "number" }, 
                   { "number"   => "9991436301", 
                     "href"     => "http://api.tropo.com/v1/applications/108000/addresses/pin/9991436300", 
                     "type"     => "pin" },
                   { "href"     => "http://api.tropo.com/v1/applications/108000/addresses/jabber/xyz123", 
                     "nickname" => "", 
                     "username" => "xyz123", 
                     "type"     => "jabber" },
                   { "href"     => "http://api.tropo.com/v1/applications/108000/addresses/jabber/xyz123", 
                     "nickname" => "", 
                     "username" => "9991436300", 
                     "type"     => "pin" },
                   { "href"     => "http://api.tropo.com/v1/applications/108000/addresses/token/a1b2c3d4", 
                     "nickname" => "", 
                     "username" => "a1b2c3d4", 
                     "type"     => "token" } ]
    
    @exchanges =  '[
                     {
                        "prefix":"1407",
                        "city":"Orlando",
                        "state":"FL",
                        "country":    "United States"
                     },
                     {
                        "prefix":"1312",
                        "city":"Chicago",
                        "state":"IL",
                            "country":"United States"
                     },
                     {
                        "prefix":"1303",
                        "city":"Denver",
                            "state":"CO",
                        "country":"United States"
                     },
                     {
                        "prefix":"1310",
                        "city":    "Los Angeles",
                        "state":"CA",
                        "country":"United States"
                     },
                     {
                        "prefix":    "1412",
                        "city":"Pittsburgh",
                        "state":"PA",
                        "country":    "United States"
                     },
                     {
                        "prefix":"1415",
                        "city":"San Francisco",
                        "state":    "CA",
                        "country":"United States"
                     },
                     {
                        "prefix":"1206",
                        "city":    "Seattle",
                        "state":"WA",
                        "country":"United States"
                     },
                     {
                        "prefix":    "1301",
                        "city":"Washington",
                        "state":"DC",
                        "country":    "United States"
                     }
                  ]'
    
    @new_account = { 'account_id' => "54219", 'href' => "http://api-eng.voxeo.net:8080/v1/users/54219" }
    
    @list_account = { 'account_id' => "54219", 'href' => "http://api-eng.voxeo.net:8080/v1/users/54219" }

    @bad_account_creds =  { "account-accesstoken-get-response" =>
                            { "accessToken"   => "", 
                              "statusMessage" => "Invalid login.", 
                              "statusCode"    => 403}}
                    
    # Register our resources
    
    # Applications with a bad uname/passwd
    FakeWeb.register_uri(:get, 
                         %r|http://bad:password@api.tropo.com/v1/applications|, 
                         :status => ["401", "Unauthorized"])

    # A specific application
    FakeWeb.register_uri(:get, 
                         "http://foo:bar@api.tropo.com/v1/applications/108000", 
                         :body => ActiveSupport::JSON.encode(@applications[0]),
                         :content_type => "application/json")
    
    # Applications
    FakeWeb.register_uri(:get, 
                         %r|http://foo:bar@api.tropo.com/v1/applications|, 
                         :body => ActiveSupport::JSON.encode(@applications), 
                         :content_type => "application/json")
    
    # Applications
    FakeWeb.register_uri(:get, 
                         %r|http://foo:bar@api.tropo.com/v1/users|, 
                         :body => ActiveSupport::JSON.encode(@applications), 
                         :content_type => "application/json")
                         
    # Create an application       
    FakeWeb.register_uri(:post, 
                         %r|http://foo:bar@api.tropo.com/v1/applications|, 
                         :body => ActiveSupport::JSON.encode({ "href" => "http://api.tropo.com/v1/applications/108016" }),
                         :status => ["200", "OK"])
    
    # Update a specific application
    FakeWeb.register_uri(:put, 
                         %r|http://foo:bar@api.tropo.com/v1/applications/108000|, 
                         :body => ActiveSupport::JSON.encode({ "href" => "http://api.tropo.com/v1/applications/108016" }),
                         :status => ["200", "OK"])
    
    # Addresses
    FakeWeb.register_uri(:get, 
                         "http://foo:bar@api.tropo.com/v1/applications/108000/addresses", 
                         :body => ActiveSupport::JSON.encode(@addresses), 
                         :content_type => "application/json")
    
    # Get a specific address
    FakeWeb.register_uri(:get, 
                         "http://foo:bar@api.tropo.com/v1/applications/108000/addresses/number/883510001812716", 
                         :body => ActiveSupport::JSON.encode(@addresses[0]),
                         :content_type => "application/json")

    # Get a address that is an IM/username
    FakeWeb.register_uri(:get, 
                         "http://foo:bar@api.tropo.com/v1/applications/108000/addresses/jabber/xyz123", 
                         :body => ActiveSupport::JSON.encode(@addresses[2]), 
                         :content_type => "application/json")

    # Get a address that is a token
    FakeWeb.register_uri(:get, 
                         "http://foo:bar@api.tropo.com/v1/applications/108000/addresses/jabber/xyz123", 
                         :body => ActiveSupport::JSON.encode(@addresses[2]), 
                         :content_type => "application/json")
                                                
    # Get a address that is a Pin
    FakeWeb.register_uri(:post, 
                         "http://foo:bar@api.tropo.com/v1/applications/108000/addresses", 
                         :body => ActiveSupport::JSON.encode(@addresses[2]),
                         :content_type => "application/json")
                                                
    # Get a address that is a token
    FakeWeb.register_uri(:get, 
                         "http://foo:bar@api.tropo.com/v1/applications/108000/addresses/token/a1b2c3d4",
                         :body => ActiveSupport::JSON.encode(@addresses[4]), 
                         :content_type => "application/json")
                                                
    # Get a address that is a number
    FakeWeb.register_uri(:post, 
                         "http://foo:bar@api.tropo.com/v1/applications/108000/addresses", 
                         :body => ActiveSupport::JSON.encode({ "href" => "http://api.tropo.com/v1/applications/108000/addresses/number/7202551912" }), 
                         :content_type => "application/json")
    
    # Create a address that is an IM account               
    FakeWeb.register_uri(:post, 
                         "http://foo:bar@api.tropo.com/v1/applications/108001/addresses", 
                         :body => ActiveSupport::JSON.encode({ "href" => "http://api.tropo.com/v1/applications/108001/addresses/jabber/xyz123@bot.im" }), 
                         :content_type => "application/json")
    
     # Create a address that is a Token         
     FakeWeb.register_uri(:post, 
                          "http://foo:bar@api.tropo.com/v1/applications/108002/addresses", 
                          :body => ActiveSupport::JSON.encode({ "href" => "http://api.tropo.com/v1/applications/108002/addresses/token/12345679f90bac47a05b178c37d3c68aaf38d5bdbc5aba0c7abb12345d8a9fd13f1234c1234567dbe2c6f63b" }), 
                          :content_type => "application/json")
                          
    # Delete an application      
    FakeWeb.register_uri(:delete, 
                         "http://foo:bar@api.tropo.com/v1/applications/108000", 
                         :body => ActiveSupport::JSON.encode({ 'message' => 'delete successful' }), 
                         :content_type => "application/json",
                         :status => ["200", "OK"])

    # Exchanges
    FakeWeb.register_uri(:get, 
                         "http://foo:bar@api.tropo.com/v1/exchanges", 
                         :body => @exchanges, 
                         :status => ["200", "OK"],
                         :content_type => "application/json")

    # Delete a address
    FakeWeb.register_uri(:delete, 
                         "http://foo:bar@api.tropo.com/v1/applications/108000/addresses/number/883510001812716", 
                         :body => ActiveSupport::JSON.encode({ 'message' => 'delete successful' }), 
                         :content_type => "application/json",
                         :status => ["200", "OK"])
    
    # Add a specific address
    FakeWeb.register_uri(:post, 
                         "http://foo:bar@api.tropo.com/v1/applications/108002/addresses/number/883510001812716", 
                         :body => ActiveSupport::JSON.encode({ 'message' => 'delete successful' }), 
                         :content_type => "application/json",
                         :status => ["200", "OK"])
    
   # Create a new account
   FakeWeb.register_uri(:get, 
                        %r|http://evolution.voxeo.com/api/account/create.jsp?|, 
                        :body => ActiveSupport::JSON.encode(@new_account), 
                        :content_type => "application/json",
                        :status => ["200", "OK"])

  # List an account
  FakeWeb.register_uri(:post, 
                       "http://foo:bar@api.tropo.com/v1/users", 
                       :body => ActiveSupport::JSON.encode(@list_account), 
                       :content_type => "application/json",
                       :status => ["200", "OK"])

   # List an account, with bad creds
   FakeWeb.register_uri(:get, 
                        "http://evolution.voxeo.com/api/account/accesstoken/get.jsp?username=foobar7474&password=fooeyfooey", 
                        :body => ActiveSupport::JSON.encode(@bad_account_creds), 
                        :content_type => "application/json",
                        :status => ["403", "Invalid Login."])
  end
  
  before(:each) do      
    @tropo_provisioning = TropoProvisioning.new('foo', 'bar')
  end
  
  it "should create a TropoProvisioning object" do
    @tropo_provisioning.instance_of?(TropoProvisioning).should == true
  end
  
  it "should get an unathorized back if there is an invalid username or password" do
    bad_credentials = TropoProvisioning.new('bad', 'password')
    begin
      response = bad_credentials.applications
    rescue => e
      e.to_s.should == '401: Unauthorized - '
    end
  end
  
  it "should get a list of applications" do
    applications = []
    @applications.each { |app| applications << app.merge({ 'application_id' => app['href'].split('/').last }) }
    
    @tropo_provisioning.applications.should == applications
  end
  
  it "should get a specific application" do
    response = @tropo_provisioning.application '108000'
    response['href'].should == @applications[0]['href']
  end
  
  it "should raise ArgumentErrors if appropriate arguments are not specified" do
    begin
      @tropo_provisioning.create_application({ :foo => 'bar' })
    rescue => e
      e.to_s.should == ':name required'
    end
    
    begin
      @tropo_provisioning.create_application({ :name      => 'foobar',
                                               :partition => 'foobar',
                                               :platform  => 'foobar' })
    rescue => e
      e.to_s.should == ':messagingUrl or :voiceUrl required'
    end
  end
  
  it "should raise ArgumentErrors if appropriate values are not passed" do
    begin
      @tropo_provisioning.create_application({ :name         => 'foobar',
                                               :partition    => 'foobar',
                                               :platform     => 'foobar',
                                               :messagingUrl => 'http://foobar' })
    rescue => e
      e.to_s.should == ":platform must be 'scripting' or 'webapi'"
    end
    
    begin
      @tropo_provisioning.create_application({ :name         => 'foobar',
                                               :partition    => 'foobar',
                                               :platform     => 'scripting',
                                               :messagingUrl => 'http://foobar' })
    rescue => e
      e.to_s.should == ":partiion must be 'staging' or 'production'"
    end
  end
  
  it "should receive an href back when we create a new application receiving an href back" do
    # With camelCase
    result = @tropo_provisioning.create_application({ :name         => 'foobar',
                                                      :partition    => 'production',
                                                      :platform     => 'scripting',
                                                      :messagingUrl => 'http://foobar' })
    result.href.should == "http://api.tropo.com/v1/applications/108016"
    result.application_id.should == '108016'
    
    # With underscores
    result = @tropo_provisioning.create_application({ :name          => 'foobar',
                                                      :partition     => 'production',
                                                      :platform      => 'scripting',
                                                      :messaging_url => 'http://foobar' })
    result.href.should == "http://api.tropo.com/v1/applications/108016"
    result.application_id.should == '108016'
  end
  
  it "should receive an href back when we update an application receiving an href back" do
    # With camelCase
    result = @tropo_provisioning.update_application('108000', { :name         => 'foobar',
                                                                :partition    => 'production',
                                                                :platform     => 'scripting',
                                                                :messagingUrl => 'http://foobar' })
    result.href.should == "http://api.tropo.com/v1/applications/108016"
    
    # With underscore
    result = @tropo_provisioning.update_application('108000', { :name          => 'foobar',
                                                                :partition     => 'production',
                                                                :platform      => 'scripting',
                                                                :messaging_url => 'http://foobar' })
    result.href.should == "http://api.tropo.com/v1/applications/108016"
  end
  
  it "should delete an application" do
    result = @tropo_provisioning.delete_application('108000')
    result.message.should == 'delete successful'
  end
  
  it "should list all of the addresses available for an application" do
    result = @tropo_provisioning.addresses('108000')
    result.should == @addresses
  end
  
  it "should list a single address when requested with a number for numbers" do
    result = @tropo_provisioning.address('108000', '883510001812716')
    result.should == @addresses[0]
  end
  
  it "should list a single address of the appropriate type when requested" do
    # First a number
    result = @tropo_provisioning.address('108000', '883510001812716')
    result.should == @addresses[0]
    
    # Then an IM username
    result = @tropo_provisioning.address('108000', 'xyz123')
    result.should == @addresses[2]
    
    # Then a pin
    result = @tropo_provisioning.address('108000', '9991436300')
    result.should == @addresses[3]
    
    # Then a token
    result = @tropo_provisioning.address('108000', 'a1b2c3d4')
    result.should == @addresses[4]
  end
  
  it "should generate an error of the addition of the address does not have a required field" do
    # Add a address without a type
    begin
      @tropo_provisioning.create_address('108000')
    rescue => e
      e.to_s.should == ":type required"
    end
    
    # Add a number without a prefix
    begin
      @tropo_provisioning.create_address('108000', { :type => 'number' })
    rescue => e
      e.to_s.should == ":prefix required to add a number address"
    end
    
    # Add a jabber without a username
    begin
      @tropo_provisioning.create_address('108000', { :type => 'jabber' })
    rescue => e
      e.to_s.should == ":username required"
    end
    
    # Add an aim without a password
    begin
      @tropo_provisioning.create_address('108000', { :type => 'aim', :username => 'joeblow@aim.com' })
    rescue => e
      e.to_s.should == ":password and required"
    end
    
    # Add a token without a channel
    begin
      @tropo_provisioning.create_address('108000', { :type => 'token' })
    rescue => e
      e.to_s.should == ":channel required"
    end
    
    # Add a token with an invalid channel type
    begin
      @tropo_provisioning.create_address('108000', { :type => 'token', :channel => 'BBC' })
    rescue => e
      e.to_s.should == ":channel must be voice or messaging"
    end
  end
  
  it "should add appropriate addresses" do  
    # Add a address based on a prefix
    result = @tropo_provisioning.create_address('108000', { :type => 'number', :prefix => '1303' })
    result[:href].should == "http://api.tropo.com/v1/applications/108000/addresses/number/7202551912"
    result[:address].should == '7202551912'
    
    # Add a jabber account
    result = @tropo_provisioning.create_address('108001', { :type => 'jabber', :username => 'xyz123@bot.im' })
    result[:href].should == "http://api.tropo.com/v1/applications/108001/addresses/jabber/xyz123@bot.im"
    result[:address].should == 'xyz123@bot.im' 
    
    # Add a token
    result = @tropo_provisioning.create_address('108002', { :type => 'token', :channel => 'voice' })
    result[:href].should == "http://api.tropo.com/v1/applications/108002/addresses/token/12345679f90bac47a05b178c37d3c68aaf38d5bdbc5aba0c7abb12345d8a9fd13f1234c1234567dbe2c6f63b"
    result[:address].should == '12345679f90bac47a05b178c37d3c68aaf38d5bdbc5aba0c7abb12345d8a9fd13f1234c1234567dbe2c6f63b'
  end
  
  it "should obtain a list of available exchanges" do
    results = @tropo_provisioning.exchanges
    results.should == ActiveSupport::JSON.decode(@exchanges)
  end
  
  it "should delete a address" do
    result = @tropo_provisioning.delete_address('108000', '883510001812716')
    result[:message].should == "delete successful"
  end
  
  it "should raise an ArgumentError if the right params are not passed to move_address" do
    begin
      @tropo_provisioning.move_address({ :to => '108002', :address => '883510001812716'})
    rescue => e
      e.to_s.should == ':from is required'
    end
    
    begin
      @tropo_provisioning.move_address({ :from => '108002', :address => '883510001812716'})
    rescue => e
      e.to_s.should == ':to is required'
    end
    
    begin
      @tropo_provisioning.move_address({ :from => '108002', :to => '883510001812716'})
    rescue => e
      e.to_s.should == ':address is required'
    end
  end
  
  it "should move a address" do
    results = @tropo_provisioning.move_address({ :from => '108000', :to => '108002', :address => '883510001812716'})
    results.should == { 'message' => 'delete successful' }
  end
  
  it "should create a new account" do
    result = @tropo_provisioning.create_account({ :username => "foobar7474", :password => 'fooey', :email => 'jsgoecke@voxeo.com' })
    result.should == @new_account
  end
  
  it "should provide a token for an existing account" do
    pending('Need to work on tests for the new account')
    result = @tropo_provisioning.account("foobar7474", 'fooey')
    result.should == @list_account
  end
  
  it "should not provide a token for an existing account if wrong credentials" do
    pending('Need to work on tests for the new account')
    begin
      result = @tropo_provisioning.account("foobar7474", 'fooeyfooey')
    rescue => e
      e.to_s.should == "403 - Invalid Login."
    end
  end
  
  it "should return accounts with associated addresses" do
    pending()
    result = @tropo_provisioning.account_with_addresses('108000')
    result.should == nil
    
    result = @tropo_provisioning.accounts_with_addresses
    result.should == nil
  end
end