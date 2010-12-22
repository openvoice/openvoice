class TropoProvisioning
  
  # Defaults for the creation of applications
  DEFAULT_OPTIONS = { :partition => 'staging', :platform  => 'scripting' }
  ##
  # Creates a new TropoProvisioning object
  #
  # @param [required, String] username for your Tropo account
  # @param [required, String] password for your Tropo account
  # @param [optional, Hash] params 
  # @option params [optional, String] :base_uri to use for accessing the provisioning API if you would like a custom one
  # @return [Object] a TropoProvisioning object
  def initialize(username, password, params={})   
    @username            = username
    @password            = password
    @base_uri            = params[:base_uri] || "http://api.tropo.com/v1"
    @headers             = { 'Content-Type' => 'application/json' }
  end
    
  def account(username, password)
    case current_method_name
    when 'account'
      action = 'get'
    when 'authenticate_account'
      action = 'authenticate'
    end
    temp_request(:get, "/#{action}.jsp?username=#{username}&password=#{password}")
  end
  alias :authenticate_account :account
  
  ##
  # Creates a new account
  #
  # @param [required, Hash] params to create the account
  #   @option params [required, String] :username the name of the user to create the account for
  #   @option params [required, String] :password the password to use for the account
  #   @option params [required, String] :email the email address to use
  #   @option params [optional, String] :brand the branding ID to use for the account
  #   @option params [optional, String] :website the URL of the user's website
  #   @option params [optional, String] :ip the IP address of the client creating the account
  #   @option params [required, String] :type the account type to create (corporate, developer, temp_developer and temp_corporate)
  # @return [Hash] returns the href of the account created
  def create_account(params={})
    # Ensure required fields are present
    raise ArgumentError, ':username required' unless params[:username]
    raise ArgumentError, ':password required' unless params[:password]
    raise ArgumentError, ':email required'    unless params[:email]

    # Set the Company Branding ID, or use default
    params[:brand] = 9 unless params[:brand]
    params[:website] = 'tropo' unless params[:website]    
    # Default is to set the account active
    params[:status] = 'active' unless params[:status]
    params = camelize_params(params)
    
    result = request(:post, { :resource => 'users', :body => params })
    result[:account_id] = get_element(result.href)
    result
  end
  
  ##
  # Creates an address to an existing application
  #
  # @param [required, String] application_id to add the address to
  # @param [required, Hash] params the parameters used to request the address
  # @option params [String] :type this defines the type of address. The possibles types are number (phone numbers), pin (reserved), token, aim, jabber, msn, yahoo, gtalk & skype
  # @option params [String] :prefix this defines the country code and area code for phone numbers
  # @option params [String] :username the messaging/IM account's username
  # @option params [String] :password the messaging/IM account's password
  # @return [Hash] params the key/values that make up the application
  # @option params [String] :href identifies the address that was added, refer to address method for details
  # @option params [String] :address the address that was created
  def create_address(application_id, params={})
    raise ArgumentError, ':type required' unless params[:type]
    
    case params[:type].downcase
    when 'number'
      raise ArgumentError, ':prefix required to add a number address' unless params[:prefix] || params[:number]
    when 'aim', 'msn', 'yahoo', 'gtalk'
      raise ArgumentError, ':username and required' unless params[:username]
      raise ArgumentError, ':password and required' unless params[:password]
    when 'jabber'
      raise ArgumentError, ':username required' unless params[:username]
    when 'token'
      raise ArgumentError, ':channel required' unless params[:channel]
      raise ArgumentError, ':channel must be voice or messaging' unless params[:channel] == 'voice' || params[:channel] == 'messaging'
    end
    
    result = request(:post, { :resource => 'applications/' + application_id.to_s + '/addresses', :body => params })
    result[:address] = get_element(result.href)
    result
  end
  
  ##
  # Get a specific application
  #
  # @param [required, String] application_id of the application to get
  # @return [Hash] params the key/values that make up the application
  # @option params [String] :href the REST address for the application
  # @option params [String] :name the name of the application
  # @option params [String] :voiceUrl the URL that powers voice calls for your application
  # @option params [String] :messagingUrl the URL that powers the SMS/messaging calls for your session
  # @option params [String] :platform defines whether the application will use the Scripting API or the Web API
  # @option params [String] :partition defines whether the application is in staging/development or production
  def application(application_id)
    app = request(:get, { :resource => 'applications/' + application_id.to_s })
    app.merge!({ :application_id => get_element(app.href) })
  end
    
  ##
  # Fetches all of the applications configured for an account
  #
  # @return [Hash] contains the results of the inquiry with a list of applications for the authenticated account, refer to the application method for details
  def applications
    results = request(:get, { :resource => 'applications' })
    result_with_ids = []
    results.each do |app|
      result_with_ids << app.merge!({ :application_id => get_element(app.href) })
    end
    result_with_ids
  end
  
  ##
  # Fetches the application(s) with the associated addresses in the hash
  #
  # @param [optional, String] application_id will return a single application with addresses if present
  # @return [Hash] contains the results of the inquiry with a list of applications for the authenticated account, refer to the application method for details
  def applications_with_addresses(application_id=nil)
    if application_id
      associate_addresses_to_application(application(application_id))
    else
      apps = []
      applications.each do |app|
        apps << associate_addresses_to_application(app)
      end
      apps
    end
  end
  alias :application_with_address :applications_with_addresses
  
  ##
  # Create a new application
  #
  # @param [required, Hash] params to create the application
  # @option params [required, String] :name the name to assign to the application
  # @option params [required, String] :partition this defines whether the application is in staging/development or production
  # @option params [required, String] :platform (scripting) whether to use scripting or the webapi
  # @option params [required, String] :messagingUrl or :messaging_url The URL that powers the SMS/messages sessions for your application
  # @option params [required, String] :voiceUrl or :voice_url the URL that powers voices calls for your application
  # @return [Hash] returns the href of the application created and the application_id of the application created
  def create_application(params={})
    merged_params = DEFAULT_OPTIONS.merge(camelize_params(params))
    validate_params merged_params
    result = request(:post, { :resource => 'applications', :body => params })
    result[:application_id] = get_element(result.href)
    result
  end
  
  ##
  # Deletes an application
  #
  # @param [required, String] application_id to be deleted
  # @return [Hash] not sure since it does 204 now, need to check with Cervantes, et al
  def delete_application(application_id)
    request(:delete, { :resource => 'applications/' + application_id.to_s })
  end
  
  ##
  # Deletes a address from a specific application
  #
  # @param [String] application_id that the address is associated to
  # @param [String] address_id for the address
  # @return
  def delete_address(application_id, address_id)
    address_to_delete = address(application_id, address_id)
    
    request(:delete, { :resource => 'applications/' + application_id.to_s + '/addresses/' + address_to_delete['type'] + '/' + address_id.to_s })
  end
  
  ##
  # Provides a list of available exchanges to obtain Numbers from
  #
  # @return [Array] the list of available exchanges
  def exchanges
    request(:get, { :resource => 'exchanges' })
  end
  
  ##
  # Used to move a address between one application and another
  #
  # @param [Hash] params contains a hash of the applications and address to move
  # @option params [required, String] :from
  # @option params [required, String] :to
  # @option params [required, String] :address
  def move_address(params={})
    raise ArgumentError, ':from is required' unless params[:from]
    raise ArgumentError, ':to is required' unless params[:to]
    raise ArgumentError, ':address is required' unless params[:address]
    
    begin
      address_to_move = address(params[:from], params[:address])
      delete_address(params[:from], params[:address])
      request(:post, { :resource => 'applications/' + params[:to] + '/addresses/' + address_to_move['type'] + '/' + params[:address]})
    rescue
      raise RuntimeError, 'Unable to move the address'
    end
  end
  
  ##
  # Get a specific address for an application
  #
  # @param [required, String] application_id to obtain the address for
  # @param [required, String] address_id of the address to obtain the details for
  # @return [Hash] the details of the address
  # @option params [String] :href the REST address for the application
  # @option params [String] :name the name of the application
  # @option params [String] :voiceUrl the URL that powers voices calls for your application
  # @option params [String] :messagingUrl The URL that powers the SMS/messages sessions for your application
  # @option params [String] :partition this defines whether the application is in staging/development or production
  # @option params [String] :type this defines the type of address. The possibles types are number (phone numbers), pin (reserved), token, aim, jabber, msn, yahoo, gtalk & skype
  # @option params [String] :prefix this defines the country code and area code for phone numbers
  # @option params [String] :number the phone number assigned to the application
  # @option params [String] :city the city associated with the assigned phone number
  # @option params [String] :state the state associated with the assigned phone number
  # @option params [String] :channel idenifites the type of channel, maybe 'voice' or 'messaging'
  # @option params [String] :username the messaging/IM account's username
  # @option params [String] :password the messaging/IM account's password
  # @option params [String] :token alphanumeric string that identifies your Tropo application, used with the Session API
  def address(application_id, address_id)
    addresses(application_id).each { |address| return address if address['number']   == address_id || 
                                                                 address['username'] == address_id || 
                                                                 address['pin']      == address_id ||
                                                                 address['token']    == address_id }
    raise RuntimeError, 'Address not found with that application.'
  end
  
  ##
  # Get all of the configured addresses for an application
  #
  # @param [required, String] application_id to fetch the addresses for
  # @return [Hash] all of the addresses configured for the application
  def addresses(application_id)
    request(:get, { :resource => 'applications/' + application_id.to_s + '/addresses' })
  end
  
  ##
  # Updated an existing application
  #
  # @param [required, String] the application id to update
  # @param [required, Hash] params the parameters used to create the application
  # @option params [optional, String] :name the name of the application
  # @option params [optional, String] :voiceUrl the URL that powers voices calls for your application
  # @option params [optional, String] :messagingUrl The URL that powers the SMS/messages sessions for your application
  # @option params [optional, String] :partition whether to create in staging or production
  # @option params [optional, String] :platform whehter to use scripting or the webapi
  # @return [Hash] returns the href of the application created
  def update_application(application_id, params={})
    request(:put, { :resource => 'applications/' + application_id.to_s, :body => params })
  end
  
  private
  
  ##
  #
  def camelize_params(params)
    camelized = {}
    params.each { |k,v| camelized.merge!(k.to_s.camelize(:lower).to_sym => v) }
    camelized
  end
  
  ##
  # Returns the current method name
  #
  # @return [String] current method name
  def current_method_name
    caller[0] =~ /`([^']*)'/ and $1
  end
  
  ##
  # Converts the hashes inside the array to Hashie::Mash objects
  #
  # @param [required, Array] array to be Hashied
  # @param [Array] array that is now Hashied
  def hashie_array(array)
    hashied_array = []
    array.each do |ele|
      hashied_array << Hashie::Mash.new(ele)
    end
    hashied_array
  end
  
  ##
  # Parses the URL and returns the last element
  #
  # @param [required, String] the URL to parse for the application ID
  # @return [String] the application id parsed from the URL
  def get_element(url)
    url.split('/').last
  end
  
  ##
  # Associates the addresses to an application
  #
  # @param [Object] application object to associate the address to
  # @return [Object] returns the application object with the associated addresses embedded
  def associate_addresses_to_application(app)
    add = addresses(app.application_id)
    app.merge!({ :addresses => add })
  end
  
  ##
  # Creates the appropriate URI and HTTP handlers for our request
  #
  # @param [required, Symbol] the HTTP action to use :delete, :get, :post or :put
  # @param [required, Hash] params used to create the request
  # @option params [String] :resource the resource to call on the base URL
  # @option params [Hash] :body the details to use when posting, putting or deleting an object, converts into the appropriate JSON
  # @return [Hash] the result of the request
  def request(method, params={})
    if params[:resource]
      uri = URI.parse(@base_uri + '/' + params[:resource])
    else
      uri = URI.parse(@base_uri)
    end
    http = Net::HTTP.new(uri.host, uri.port)

    request = set_request_type(method, uri)
    request.initialize_http_header(@headers)
    request.basic_auth @username, @password
    request.body = ActiveSupport::JSON.encode params[:body] if params[:body]
    response = http.request(request)
    
    raise RuntimeError, "#{response.code}: #{response.message} - #{response.body}" unless response.code == '200'

    result = ActiveSupport::JSON.decode response.body
    if result.instance_of? Array
      hashie_array(result)
    else
      Hashie::Mash.new(result)
    end
  end
  
  ##
  # Creates the appropriate request for the temporary Evolution account API
  #
  # @return [Hash] the result of the request
  def temp_request(method, fields)
    base_uri = 'http://evolution.voxeo.com/api/account'
    uri = URI.parse(base_uri + fields)
    http = Net::HTTP.new(uri.host, uri.port)

    request = set_request_type(method, uri)
    request.initialize_http_header(@headers)

    response = http.request(request)
    raise RuntimeError, "#{response.code} - #{response.message}" unless response.code == '200'

    result = ActiveSupport::JSON.decode response.body
    if result.instance_of? Array
      hashie_array(result)
    else
      Hashie::Mash.new(result)
    end
  end
  
  ##
  # Sets the HTTP REST type based on the method being called
  # 
  # @param [required, ymbol] the HTTP method to use, may be :delete, :get, :post or :put
  # @param [Object] the uri object to create the request for
  # @return [Object] the request object to be used to operate on the resource
  def set_request_type(method, uri)
    case method
    when :delete
      Net::HTTP::Delete.new(uri.request_uri)
    when :get
      Net::HTTP::Get.new(uri.request_uri)
    when :post
      Net::HTTP::Post.new(uri.request_uri)
    when :put
      Net::HTTP::Put.new(uri.request_uri)
    end
  end
  
  ##
  # Validates that we have all of the appropriate params when creating an application
  #
  # @param [Hash] params to create the application
  # @option params [required, String] :name the name to assign to the application
  # @option params [required, String] :partition whether to create in staging or production
  # @option params [required, String] :platform whehter to use scripting or the webapi
  # @option params [String] :messagingUrl the Url to use for handiling messaging requests
  # @option params [String] :voiceUrl the Url to use for handling voice requests
  # @return nil
  def validate_params(params={})
    # Make sure all of the arguments are present
    raise ArgumentError, ':name required' unless params[:name]
    raise ArgumentError, ':messagingUrl or :voiceUrl required' unless params[:messagingUrl] || params[:voiceUrl]
    
    # Make sure the arguments have valid values
    raise ArgumentError, ":platform must be 'scripting' or 'webapi'" unless params[:platform] == 'scripting' || params[:platform] == 'webapi'
    raise ArgumentError, ":partiion must be 'staging' or 'production'" unless params[:partition] == 'staging' || params[:partition] == 'production'
  end
end