module Tropo
  module Helpers
    private
      
      ##
      # Method checks for presence of required elements and then builds the action
      #
      # @param [String] the name of the action to build
      # @param [Hash] the elements to be used to build the action
      # @return [Hash] provides the properply built hash for the action
      def build_action(action, params)
        raise ArgumentError, 'Action requires parameters' if params.nil?
      
        case action
        when 'ask'
          has_params?(params, 'ask', 'name')
        when 'choices'
          if params[:mode] 
            if params[:mode] != 'dtmf' && params[:mode] != 'speech'
              raise ArgumentError, "If mode is provided, only 'dtmf', 'speech' or 'any' is supported"
            end
          end
        when 'conference'
          has_params?(params, 'conference', ['name', 'id'])
        when 'on'
          has_params?(params, 'on', 'event')
        when 'record'
          has_params?(params, 'record', ['name', 'url'])
        when 'start_recording'
          has_params?(params, 'start_recording', ['url'])
          
          # Camelcase this one to be Java friendly
          action = 'startRecording'
        when 'redirect'
          has_params?(params, 'redirect', 'to')
          raise ArgumentError, "Redirect should only be used alone and before the session is answered, use transfer instead" if @nested_hash
        when 'say'
          has_params?(params, 'say', 'value')
          return build_elements(params)
        when 'transfer'
          has_params?(params, 'transfer', 'to')
        end
      
        if action == 'on'
          build_elements(params)
        else
          { action.to_sym => build_elements(params) }
        end
      end
      
      ##
      # Checks to see if certain parameters are present, and if not raises an error
      #
      # @overload has_params?(params, action, names)
      #   @param [Hash] the parameter hash to be checked for the presence of a parameter
      #   @param [String] the action being checked
      #   @param [String] the name of the key in the params that must be present
      # @overload has_params?(params, action, names)
      #   @param [Hash] the parameter hash to be checked for the presence of a parameter
      #   @param [String] the action being checked
      #   @param [Array] a list of names of the keys in the params that must be present
      def has_params?(params, action, names)
        if names.kind_of? Array
          names.each { |name| raise ArgumentError, "A '#{name}' must be provided to a '#{action}' action" if params[name.to_sym].nil? }
        else
          raise ArgumentError, "A '#{names}' must be provided to a '#{action}' action" if params[names.to_sym].nil?
        end
      end
      
      # Takes a Ruby underscore string and converts to a Java friendly camelized string
      #
      # @param [String] the string to be camelized
      # @return [String] the Ruby string camelized
      def camelize(ruby_string)
        split_string = ruby_string.split('_')
        return_string = split_string[0] + split_string[1].capitalize
        return_string = return_string + split_string[2].capitalize if split_string[2]
        return_string
      end
    
      ##
      # Creates a nested hash when we have block within a block
      #
      # @param [String] the name of the action being built
      # @param [Hash] the parameters to be added to the action
      # @return [nil]
      def create_nested_hash(name, params)
        @nested_hash = build_action(name, params)
        @nested_name = name
      end

      ##
      # Creates a nested hash specfic to 'on', as an on may have an additional block
      #
      # @param [Hash] the parameters to be added to the instance of the 'on' action
      # @return [nil]
      def create_nested_on_hash(params)
        @nested_on_hash ||= { :on => Array.new }
        @nested_on_hash_cnt ||= 0
        @nested_on_hash[:on] << params
      end
          
      ##
      # Creates an on_hash for the on action
      #
      # @return [nil]
      def create_on_hash
        @on_hash ||= { :on => Array.new }
      end
      
      ##
      # Method builds the elements for each of the actions
      #
      # @param [Hash] the individual elements to be used to build the hash
      # @return [Hash] returns the elements properly formatted in a hash
      def build_elements(params)
        if params[:url]
          uri = URI.parse params[:url]
          # Check to see if it is a valid http address
          if uri.class != URI::HTTP
            # Check to see if it is a valid email address
            if params[:url].match(/^[a-zA-Z][\w\.-]*[a-zA-Z0-9]@[a-zA-Z0-9][\w\.-]*[a-zA-Z0-9]\.[a-zA-Z][a-zA-Z\.]*[a-zA-Z]$/) == false
              raise ArgumentError, "The 'url' paramater must be a valid URL"
            end
          end
        end
      
        hash = Hash.new
        params.each_pair do |k,v| 
          if k.to_s.include? "_"
            k = camelize k.to_s
            k = k.to_sym if k
          end
          hash.merge!({ k => v })
        end
        hash
      end
    
      ##
      # Takes a Java Camelized string and converts to an underscore string
      #
      # @param [String] the string to be de-camelized
      # @return [String] the Ruby string with an underscore and no capitals
      def decamelize(camel_string)
        camel_string.gsub(/[A-Z]/) { |char| '_' + char.downcase }
      end
      
      ##
      # Formats the @response instance variable to JSON before making it available to the accessor
      #
      # @return [nil]`
      def render_response
        @response.to_json
      end
      
      ##
      # Determines if there is a voice or recognizer specified, if not set it to the default specified and if not default leave it alone
      # this is for the speech synthesis and speech recognition language to use on a say/ask methods
      #
      # @params [Hash] the array of values to check if a voice and recognizer are present
      # @return [Hash] Will return the params with the appropriate voice/recognizer values set
      def set_language(params)
        params.merge!({ :recognizer => @recognizer }) if params[:recognizer].nil? && @recognizer
        params.merge!({ :voice => @voice }) if params[:voice].nil? && @voice
        params
      end
      
      ##
      # Returns an hash from a collapsed array, using the values of 'key' or 'name' as the collpassed hash key
      #
      # @param [Array] the array of values to collapse into a Hash
      # @return [Hash] the collapsed Hash
      def transform_array(array)
        transformed_to_hash = Hash.new

        array.each_with_index do |ele, i|
          # Set the key to the value of the respresentative key
          key = ele['key'] if ele['key']
          key = ele['name'] if ele['name']
        
          # Merge this new key into the hash
          transformed_to_hash.merge!({ key => Hash.new })
        
          # Then add the corresponding key/values to this new hash
          ele.each_pair do |k, v|
            if k != 'key' && k != 'name'
              transformed_to_hash[key].merge!(transform_pair(k, v))
            end
          end
        end

        transformed_to_hash
      end

      ##
      # Transforms a hash into the appropriatey formatted hash with no camelcase and keys as symbols
      #
      # @param [Hash] Hash to be transformed
      # @return [Hash] the transformed hash
      def transform_hash(hash)
        transformed_hash = Hash.new
        hash.each_pair { |k, v| transformed_hash.merge!(transform_pair(k, v)) }
        transformed_hash
      end

      ##
      # Transforms a single keypair into a decamelized symbol with the appropriate value. Also converts
      # any timestamps to a Ruby Time object
      #
      # @param[String] the key to be decamelized and symobolized
      # @param[Hash] the newly created hash that contins the properly formatted key
      def transform_pair(key, value)
        hash = { decamelize(key) => value }
        hash['timestamp'] = Time.parse(value) if hash['timestamp']
        if hash['actions']
          if hash['actions']['name']
            key_name = hash['actions']['name']
            hash['actions'].delete('name')
            hash['actions'] = { key_name => hash['actions'] }
          end
        end
        set_session_type(hash) if hash['channel']
        hash
      end
      
      ##
      # Sets the session type instance variables of voice_session and text_session
      #
      # @param[Hash] the key, value pair of the channel 
      # @return nil
      def set_session_type(hash)
        case hash['channel']
        when "VOICE"
          @voice_session = true
          @text_session = false
        when "TEXT"
          @text_session = true
          @voice_session = false
        end
      end
  end
end