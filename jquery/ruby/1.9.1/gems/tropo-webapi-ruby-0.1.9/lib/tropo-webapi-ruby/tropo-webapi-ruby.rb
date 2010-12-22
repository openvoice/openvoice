# @author Jason Goecke
module Tropo
  class Generator 
    include Tropo::Helpers
    
    ##
    # Set a couple of Booleans to indicate the session type as a convenience 
    # Set a default voice for speech synthesis
    # Set a default recognizer for speech recognition
    attr_reader :voice_session, :text_session, :voice, :recognizer
    
    ##
    # Defines the actions on self so that we may call them individually
    #
    # @return [nil]
    class << self
      def method_missing(method_id, *args, &block)
        g = Generator.new
        g.send(method_id, *args, &block)
      end
    end
    
    ##
    # Initializes the Generator class
    #
    # @overload initialize()
    # @overload initialize(params)
    #   @param [String] voice sets the value of the default voice
    #   @param [Object] pass in an object that may be accessed inside the block
    # @overload initialize(params, &block)
    #   @param [Object] pass in an object that may be accessed inside the block
    #   @param [String] voice sets the value of the default voice
    #   @param [Block] a block of code to execute (optional)
    # @return [Object] a new Generator object
    def initialize(params={}, &block)
      @response = { :tropo => Array.new }
      @voice = params[:voice] if params[:voice]
      @recognizer = params[:recognizer] if params[:recognizer]
      
      if block_given?
        # Lets us know were are in the midst of building a block, so we only rendor the JSON
        # response at the end of executing the block, rather than at each action
        @building = true
        instance_exec(&block)
        render_response
      end
    end
    
    ##
    # Prompts the user (audio file or text to speech) and optionally waits for a response from the user. 
    # If collected, responses may be in the form of DTMF, speech recognition or text using a grammar or 
    # free-form text.
    #
    # @overload ask(params)
    #   @param [Hash] params the options to create an ask action request with.
    #   @option params [String] :name the name to assign to the result when returned to the application, default is true
    #   @option params [optional, Integer] :attempts (1) the number of times to prompt the user for input
    #   @option params [optional, Boolean] :bargein (true) allows a user to enter a key to stop the ask action
    #   @option params [optional, Float] :min_confidence (.5) the minimum confidence by which to accept the response expressed from 0-1, as opposed to asking again
    #   @option params [optional, Boolean] :required (true) if this is a field that must be completed by the user
    #   @option params [optional, Integer] :timeout (30) the amount of time, in seconds, to wait for a response before moving on
    # @overload ask(params, &block)
    #   @param [Hash] params the options to create an ask action request with.
    #   @param [Block] takes a block so that you may trigger actions, such as a say, on a specific event
    #   @option params [String] :name the name to assign to the result when returned to the application
    #   @option params [optional, Integer] :attempts (1) the number of times to prompt the user for input
    #   @option params [optional, Boolean] :bargein (true) allows a user to enter a key to stop the ask action
    #   @option params [optional, Float] :min_confidence (.5) the minimum confidence by which to accept the response expressed from 0-1, as opposed to asking again
    #   @option params [optional, Boolean] :required (true) if this is a field that must be completed by the user
    #   @option params [optional, Integer] :timeout (30) the amount of time, in seconds, to wait for a response before moving on
    # @return [String, nil] the JSON string to be passed back to Tropo or nil
    #   if the method has been called from inside a block
    def ask(params={}, &block)
      params = set_language(params)
      if block_given?
        create_nested_hash('ask', params)
        instance_exec(&block)
        @response[:tropo] << @nested_hash
      else
        hash = build_action('ask', params)
        @response[:tropo] << hash
      end
      render_response if @building.nil?
    end
    alias :prompt :ask
    
    ##
    # Prompts initiates a new call. May only be used when no call is active.
    #
    # @overload call(params)
    #   @param [Hash] params the options to create a call action request with.
    #   @option params [String] :to the destination of the call, may be a phone number, SMS number or IM address
    #   @option params [optional, String] :from the phone number or IM address the call will come from
    #   @option params [optional, String] :network which network the call will be initiated with, such as SMS
    #   @option params [optional, String] :channel the channel the call will be initiated over, may be TEXT or VOICE
    #   @option params [optional, Integer] :timeout (30) the amount of time, in seconds, to wait for a response before moving on
    #   @option params [optional, Boolean] :answer_on_media (true) 
    #   @options params [optional, Hash] :headers A set of key/values to apply as customer SIP headers to the outgoing call
    #   @options params [optional, Hash] :recording Refer to the recording method for paramaters in the hash
    # @overload ask(params, &block)
    #   @param [Hash] params the options to create an message action request with.
    #   @param [Block] takes a block so that you may trigger actions, such as a say, on a specific event
    #   @option params [String] :to the destination of the call, may be a phone number, SMS number or IM address
    #   @option params [optional, String] :from the phone number or IM address the call will come from
    #   @option params [optional, String] :network which network the call will be initiated with, such as SMS
    #   @option params [optional, String] :channel the channel the call will be initiated over, may be TEXT or VOICE
    #   @option params [optional, Integer] :timeout (30) the amount of time, in seconds, to wait for a response before moving on
    #   @option params [optional, Boolean] :answer_on_media (true) 
    #   @options params [optional, Hash] :headers A set of key/values to apply as customer SIP headers to the outgoing call
    #   @options params [optional, Hash] :recording Refer to the recording method for paramaters in the hash
    # @return [String, nil] the JSON string to be passed back to Tropo or nil
    #   if the method has been called from inside a block
    def call(params={}, &block)
      if block_given?
        create_nested_hash('call', params)
        instance_exec(&block)
        @response[:tropo] << @nested_hash
      else
        hash = build_action('call', params)
        @response[:tropo] << hash
      end
      render_response if @building.nil?
    end
    
    ##
    # Choices to give the user on input
    #
    # @param [Hash] params the options used to construct the grammar for the user
    # @option params [String] :value the name to assign to the result when returned to the app
    # @option params [optional, String] :mode (ANY) the mode to use when asking the user [DTMF, SPEECH or ANY]
    # @option params [optional, String] :term_char the user may enter a keypad entry to stop the request
    # @option params [optional, String] :type (simple/grammar) the type of grammar to use
    # @option [String, nil] the JSON string to be passed back to Tropo or nil
    #   if the method has been called from inside a block
    def choices(params={})
      hash = build_action('choices', params)
      
      if @nested_hash
        @nested_hash[@nested_name.to_sym].merge!(hash)
      else
        @response[:tropo] << hash
        render_response if @building.nil?
      end
    end
    
    ##
    # Creates a conference or pushes a user to an existing conference
    #
    # @overload conference(params)
    #   @param [Hash] params the options to create a message with.
    #   @option params [String] :name the name to assign to the conference room and to identify events back to the application
    #   @option params [Integer] :id the number to assign to the conference room
    #   @option params [optional, Boolean] :mute (false) whether to mute this caller in the conference
    #   @option params [optional, Integer] :max_time the maximum time, in seconds, to allow this user to stay in conference
    #   @option params [optional, Integer] :send_tones whether to send the DTMF a user may enter to the audio of the conference
    #   @option params [optional, String] :exit_tone whether to play a beep when this user exits a conference
    # @overload conference(params, &block)
    #   @param [Hash] params the options to create a message with.
    #   @param [Block] takes a block so that you may trigger actions, such as a say, on a specific event
    #   @option params [String] :name the name to assign to the conference room and to identify events back to the application
    #   @option params [Integer] :id the number to assign to the conference room
    #   @option params [optional, Boolean] :mute (false) whether to mute this caller in the conference
    #   @option params [optional, Integer] :max_time the maximum time, in seconds, to allow this user to stay in conference
    #   @option params [optional, Integer] :send_tones whether to send the DTMF a user may enter to the audio of the conference
    #   @option params [optional, String] :exit_tone whether to play a beep when this user exits a conference
    # @return [String, nil] the JSON string to be passed back to Tropo or nil
    #   if the method has been called from inside a block
    def conference(params={}, &block)
      if block_given?
        create_nested_hash('conference', params)
        instance_exec(&block)
        @response[:tropo] << @nested_hash
      else
        hash = build_action('conference', params)
        @response[:tropo] << hash
      end
      render_response if @building.nil?
    end
    
    ##
    # This function instructs Tropo to "hang-up" or disconnect the current session.
    #
    # May trigger these events:
    #   - hangup
    #   - error
    #
    # @return [String, nil] returns the JSON string to hangup/stop the current session or nil
    #   if the method has been called from inside a block
    def hangup
      @response[:tropo] << { :hangup => nil }
      render_response if @building.nil? 
    end
    alias :disconnect :hangup
    
    ##
    # Message initiates a new message to a destination and then hangs up on that destination. Also takes a say method
    # in order to deliver a message to that desintation and then hangup.
    #
    # @overload message(params)
    #   @param [Hash] params the options to create a message action request with.
    #   @option params [String] :to the destination of the call, may be a phone number, SMS number or IM address
    #   @option params [optional, String] :from the phone number or IM address the call will come from
    #   @option params [optional, String] :network which network the call will be initiated with, such as SMS
    #   @option params [optional, String] :channel the channel the call will be initiated over, may be TEXT or VOICE
    #   @option params [optional, Integer] :timeout (30) the amount of time, in seconds, to wait for a response before moving on
    #   @option params [optional, Boolean] :answer_on_media (true) 
    #   @options params [optional, Hash] :headers A set of key/values to apply as customer SIP headers to the outgoing call
    #   @options params [optional, Hash] :recording Refer to the recording method for paramaters in the hash
    # @overload ask(params, &block)
    #   @param [Hash] params the options to create an message action request with.
    #   @param [Block] takes a block so that you may trigger actions, such as a say, on a specific event
    #   @option params [String] :to the destination of the call, may be a phone number, SMS number or IM address
    #   @option params [optional, String] :from the phone number or IM address the call will come from
    #   @option params [optional, String] :network which network the call will be initiated with, such as SMS
    #   @option params [optional, String] :channel the channel the call will be initiated over, may be TEXT or VOICE
    #   @option params [optional, Integer] :timeout (30) the amount of time, in seconds, to wait for a response before moving on
    #   @option params [optional, Boolean] :answer_on_media (true) 
    #   @options params [optional, Hash] :headers A set of key/values to apply as customer SIP headers to the outgoing call
    #   @options params [optional, Hash] :recording Refer to the recording method for paramaters in the hash
    # @return [String, nil] the JSON string to be passed back to Tropo or nil
    #   if the method has been called from inside a block
    def message(params={}, &block)
      if block_given?
        create_nested_hash('message', params)
        instance_exec(&block)
        @response[:tropo] << @nested_hash
      else
        hash = build_action('message', params)
        @response[:tropo] << hash
      end
      render_response if @building.nil?
    end
    
    ##
    # Sets event handlers to call a REST resource when a particular event occurs
    #
    # @overload initialize(params)
    #   @param [Hash] params the options to create a message with.
    #   @option params [String] :event the event name that should trigger the callback
    #   @option params [String] :next the resource to send the callback to, such as '/error.json'
    # @overload initialize(params, &block)
    #   @param [Hash] params the options to create a message with.
    #   @option params [String] :event the event name that should trigger the callback
    #   @option params [String] :next the resource to send the callback to, such as '/error.json'
    #   @param [Block] takes a block so that you may trigger actions, such as a say, on a specific event
    # @option [String, nil] the JSON string to be passed back to Tropo or nil
    #   if the method has been called from inside a block
    def on(params={}, &block)
      if block_given?
        create_nested_on_hash(params)
        instance_exec(&block)
        if @nested_hash
          @nested_hash[@nested_name.to_sym].merge!(@nested_on_hash)
        end
      else
        create_on_hash
        hash = build_action('on', params)
        @on_hash[:on] << hash
        if @nested_hash
          @nested_hash[@nested_name.to_sym].merge!(@on_hash)
        else
          @response[:tropo] << { :on => hash }
          render_response if @building.nil?
        end
      end
    end

    ##
    # Parses the JSON string recieved from Tropo into a Ruby Hash, or 
    # if already a Ruby Hash parses it with the nicities provided by
    # the gem
    #
    # @param [String or Hash] a JSON string or a Ruby Hash
    # @return [Hash] a Hash representing the formatted response from Tropo
    def parse(response)
      response = JSON.parse(response) if response.class == String

      # Check to see what type of response we are working with
      if response['session']
        transformed_response = { 'session' => { } }
        
        response['session'].each_pair do |key, value|
          value = transform_hash value if value.kind_of? Hash
          transformed_response['session'].merge!(transform_pair(key, value))
        end
        
      elsif response['result']
        transformed_response = { 'result' => { } }

        response['result'].each_pair do |key, value|
          value = transform_hash value if value.kind_of? Hash
          value = transform_array value  if value.kind_of? Array
          transformed_response['result'].merge!(transform_pair(key, value))
        end
      end

      transformed_response = Hashie::Mash.new(transformed_response)
    end
    
    ##
    # Sets the default recognizer for the object
    #
    # @param [String] recognizer the value to set the default voice to
    def recognizer=(recognizer)
      @recognizer = recognizer
    end
    
    ##
    # Plays a prompt (audio file or text to speech) and optionally waits for a response from the caller that is recorded. 
    # If collected, responses may be in the form of DTMF or speech recognition using a simple grammar format defined below. 
    # The record funtion is really an alias of the prompt function, but one which forces the record option to true regardless of how it is (or is not) initially set. 
    # At the conclusion of the recording, the audio file may be automatically sent to an external server via FTP or an HTTP POST/Multipart Form. 
    # If specified, the audio file may also be transcribed and the text returned to you via an email address or HTTP POST/Multipart Form.
    #
    # @overload record(params)
    #   @param [Hash] params the options to create a message with.
    #   @option params [String] :name the event name that should trigger the callback
    #   @option params [String] :url a valid URI, an HTTP, FTP or email address to POST the recording file to
    #   @option params [optional, String] :format (audio/wav) the audio format to record in, either a wav or mp3
    #   @option params [optional, String] :username if posting to FTP, the username for the FTP server
    #   @option params [optional, String] :password if posting to FTP, the password for the FTP server
    #   @option params [optional, Hash] :transcription parameters used to transcribe the recording
    # @overload record(params, &block)
    #   @param [Hash] params the options to create a message with.
    #   @param [Block] takes a block so that you may trigger actions, such as a say, on a specific event
    #   @option params [String] :name the event name that should trigger the callback
    #   @option params [String] :url a valid URI, an HTTP, FTP or email address to POST the recording file to
    #   @option params [optional, String] :format (audio/wav) the audio format to record in, either a wav or mp3
    #   @option params [optional, String] :username if posting to FTP, the username for the FTP server
    #   @option params [optional, String] :password if posting to FTP, the password for the FTP server
    #   @option params [optional, Hash] :transcription parameters used to transcribe the recording
    # @option [String, nil] the JSON string to be passed back to Tropo or nil
    #   if the method has been called from inside a block
    def record(params={}, &block)
      if block_given?
        create_nested_hash('record', params)
        instance_exec(&block)
        @response[:tropo] << @nested_hash
      else
        hash = build_action('record', params)
        @response[:tropo] << hash
      end
      render_response if @building.nil?
    end
    
    ##
    # The redirect function forwards an incoming call to another destination / phone number before answering it. 
    # The redirect function must be called before answer is called; redirect expects that a call be in the ringing or answering state. 
    # Use transfer when working with active answered calls.
    #
    #  tel: classic phone number (See RFC 2896), must be proceeded by a + and the country code (ie - +14155551212 for a US #)
    #  sip: Session Initiation Protocol (SIP) address
    #
    # @param [Hash] params the options to create a message with.
    # @option params [required, String] :to where to redirect the session to
    # @option params [optional, String] :from set the from id for the session when redirecting
    # @return [String, nil] the JSON string to redirect the current session or nil
    #   if the method has been called from inside a block
    def redirect(params={})
      hash = build_action('redirect', params)
      @response[:tropo] << hash
      render_response if @building.nil?
    end
    
    ##
    # Allows Tropo applications to reject incoming calls before they are answered. 
    # For example, an application could inspect the callerID variable to determine if the caller is known, 
    # and then use the reject call accordingly.
    #
    # @return [String, nil] the JSON string to reject the current session or nil
    #   if the method has been called from inside a block
    def reject
      @response[:tropo] << { :reject => nil }
      render_response if @building.nil?
    end
    
    ##
    # Renders the JSON string to be sent to Tropo to execute a set of actions
    #
    # @return [String] the JSON string to be sent to the Tropo Remote API
    def response
      @response.to_json
    end
    
    ##
    # Resets the action hash if one desires to reuse the same Generator object
    #
    # @return [nil]
    def reset
      @response = { :tropo => Array.new }
      @voice_session = false
      @text_session = false
    end
    
    ##
    # Plays a prompt (audio file, text to speech or text for IM/SMS). There is no ability to wait for a response from a user.
    # An audio file used for playback may be in one of the following two formats:
    #  Wav 8bit 8khz Ulaw
    #  MP3
    #
    # @overload say(params)
    #   @param [Hash] params the options to create a message with.
    #   @option params [String] :value the text or audio to be spoken or played back to the user
    #   @option params [Boolean] :event assigns a callback when a particular event occurs
    #   @option params [Integer] :as instructs the engine on how to handle the grammar
    #   @option params [Boolean] :format instructs the engine on how to handle the grammar
    #   @return [String, nil] the JSON string to be passed back to Tropo or nil
    #     if the method has been called from inside a block
    # @overload say(value, params)
    #   @param [String] the text or audio to be spoken or played back to the user
    #   @param [Hash] params the options to create a message with.
    #   @option params [Boolean] :event assigns a callback when a particular event occurs
    #   @option params [Integer] :as instructs the engine on how to handle the grammar
    #   @option params [Boolean] :format instructs the engine on how to handle the grammar
    #   @return [String, nil] the JSON string to be passed back to Tropo or nil
    #     if the method has been called from inside a block
    def say(value=nil, params={})
      
      # This will allow a string to be passed to the say, as opposed to always having to specify a :value key/pair,
      # or still allow a hash or Array to be passed as well
      if value.kind_of? String
        params[:value] = value
      elsif value.kind_of? Hash
        params = value
      elsif value.kind_of? Array
        params = value
      else
        raise ArgumentError, "An invalid paramater type #{value.class} has been passed"
      end
      
      response = { :say => Array.new }

      if params.kind_of? Array
        params.each do |param|
          param = set_language(param)
          hash = build_action('say', param)
          response[:say] << hash
        end
      else
        params = set_language(params)
        hash = build_action('say', params)
        response[:say] << hash
      end
      
      if @nested_hash && @nested_on_hash.nil?
        @nested_hash[@nested_name.to_sym].merge!(response)
      elsif @nested_on_hash
        @nested_on_hash[:on][@nested_on_hash_cnt].merge!(response)
        @nested_on_hash_cnt += 1
      else
        @response[:tropo] << response
        render_response if @building.nil?
      end
    end
    
    ##
    # Allows Tropo applications to begin recording the current session. 
    # The resulting recording may then be sent via FTP or an HTTP POST/Multipart Form.
    #
    # @param [Hash] params the options to create a message with.
    # @option params [String] :url a valid URI, an HTTP, FTP or email address to POST the recording file to
    # @option params [optional, String] :format (audio/wav) the audio format to record in, either a wav or mp3
    # @option params [optional, String] :username if posting to FTP, the username for the FTP server
    # @option params [optional, String] :password if posting to FTP, the password for the FTP server
    # @return [String, nil] returns the JSON string to start the recording of a session or nil
    #   if the method has been called from inside a block
    def start_recording(params={})
      if block_given?
        create_nested_hash('start_recording', params)
        instance_exec(&block)
        @response[:tropo] << @nested_hash
      else
        hash = build_action('start_recording', params)
        @response[:tropo] << hash
      end
      render_response if @building.nil?
    end
    alias :start_call_recording :start_recording

    ##
    # Stops the recording of the current session after startCallRecording has been called
    #
    # @return [String, nil] returns the JSON string to stop the recording of a session or nil
    #   if the method has been called from inside a block
    def stop_recording
      @response[:tropo] << { :stopRecording => nil }
      render_response if @building.nil?
    end
    alias :stop_call_recording :stop_recording
    
    ##
    # Transfers an already answered call to another destination / phone number. 
    # Call may be transferred to another phone number or SIP address, which is set through the "to" parameter and is in URL format. 
    # Supported formats include:
    #  tel: classic phone number (See RFC 2896), must be proceeded by a + and the country code (ie - +14155551212 for a US #)
    #  sip: SIP protocol address
    #
    # When this method is called the following occurs:
    #  The audio file specified in playvalue is played to the existing call. This could be "hold music", a ring-back sound, etc. The audio file is played up to playrepeat times.
    #  While audio is playing, a new call is initiated to the specified "to" address using the callerID specified.
    #  If answerOnMedia is true, the audio from the new call is connected to the existing call immediately.
    #  The system waits for an answer or other event from the new call up to the timeout.
    #  If the call successfully completes within the timeout, the existing call and new call will be connected, onSuccess will be called, and the transfer call will return a success event.
    #  If the call fails before the timeout, onCallFailure will be called and the method will return an onCallFailure event.
    #  If the call fails due to the timeout elapsing, onTimeout will be called and the method will return a timeout event
    #
    # @overload transfer(params)
    #   @param [Hash] params the options to create a transfer action request with
    #   @option params [String] :name the name to assign to the result when returned to the application, default is true
    #   @option params [optional, Boolean] :answer_on_media ???
    #   @option params [optional, Integer] :answer_timeout the amount of time to ring the far side before giving up and going to the next step
    #   @option params [optional, Boolean] :required (true) ???
    #   @option params [required, String] :to where to redirect the session to
    #   @option params [optional, String] :from set the from id for the session when redirecting
    #   @option params [optional, Integer] :ring_repeat ???
    # @overload transfer(params, &block)
    #   @param [Hash] params the options to create a transfer action request with
    #   @option params [String] :name the name to assign to the result when returned to the application, default is true
    #   @option params [optional, Boolean] :answer_on_media ???
    #   @option params [optional, Integer] :answer_timeout the amount of time to ring the far side before giving up and going to the next step
    #   @option params [optional, Boolean] :required (true) ???
    #   @option params [required, String] :to where to redirect the session to
    #   @option params [optional, String] :from set the from id for the session when redirecting
    #   @option params [optional, Integer] :ring_repeat ???
    # @return [nil, String]
    def transfer(params={}, &block)
      if block_given?
        create_nested_hash('transfer', params)
        instance_exec(&block)
        @response[:tropo] << @nested_hash
      else
        hash = build_action('transfer', params)
        @response[:tropo] << hash
      end
      render_response if @building.nil?
    end
    
    ##
    # Returns the current hash object of the response, as opposed to JSON
    #
    # @return [Hash] the current hash of the response
    def to_hash
      @response
    end
    
    ##
    # Sets the default voice for the object
    #
    # @param [String] voice the value to set the default voice to
    def voice=(voice)
      @voice = voice
    end
  end
end