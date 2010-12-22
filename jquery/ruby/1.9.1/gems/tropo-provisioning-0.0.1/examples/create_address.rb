require 'rubygems'
require 'yaml'
require 'lib/tropo-provisioning'

config = YAML.load(File.open('examples/config.yml'))
app_details = YAML.load(File.open("examples/#{config['filename']}"))

# Create a new provisioning object with your Tropo credentials
provisioning = TropoProvisioning.new(config['tropo']['username'], config['tropo']['password'], :base_uri => 'https://api.voxeo.com/v1')

# Add a address by prefix
p provisioning.create_address(app_details.application_id, { :type => 'number', :prefix => provisioning.exchanges[0]['prefix'] })

# Add a address with a specific numbers
# p provisioning.add_address(app_details.application_id, { :type => 'number', :number => '13035551212' })

# Add an instant messaging address
p provisioning.create_address(app_details.application_id, { :type => 'jabber', :username => 'xyz123@bot.im' })