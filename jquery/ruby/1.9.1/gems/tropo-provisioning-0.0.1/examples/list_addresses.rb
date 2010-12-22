require 'rubygems'
require 'lib/tropo-provisioning'

config = YAML.load(File.open('examples/config.yml'))
app_details = YAML.load(File.open("examples/#{config['filename']}"))

# Create a new provisioning object with your Tropo credentials
provisioning = TropoProvisioning.new(config['tropo']['username'], config['tropo']['password'])

# Then you may iterate through all of your configured addresses
provisioning.addresses(app_details.application_id).each do |address|
  p address
  puts '*'*10
end

# Then, lets fetch a single address where the first param is the application ID and the second the associated address ID
p provisioning.address(app_details.application_id, '883510001812716')
p provisioning.address(app_details.application_id, 'xyz123')