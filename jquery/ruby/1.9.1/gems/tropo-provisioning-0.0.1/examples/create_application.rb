require 'rubygems'
require 'active_record'
require 'yaml'
require 'lib/tropo-provisioning'

config = YAML.load(File.open('examples/config.yml'))

# Create a new provisioning object with your Tropo credentials
provisioning = TropoProvisioning.new(config['tropo']['username'], config['tropo']['password'])

# Then create the application you would like to
result = provisioning.create_application({ :name         => 'Provisioning Test',
                                           #:voiceUrl     => 'http://mydomain.com/voice_script.rb',
                                           :partition    => 'staging',
                                           :messagingUrl => 'http://mydomain.com/message_script.rb',
                                           :platform     => 'scripting' })

File.open("examples/#{config['filename']}", 'w') do |f|
  f.write(result.to_yaml)
end

p result