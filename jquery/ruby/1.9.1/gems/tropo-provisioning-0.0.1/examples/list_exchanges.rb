require 'rubygems'
require 'lib/tropo-provisioning'

config = YAML.load(File.open('examples/config.yml'))

# Create a new provisioning object with your Tropo credentials
provisioning = TropoProvisioning.new(config['tropo']['username'], config['tropo']['password'])

# Then you may iterate through all of the available exchanges
provisioning.exchanges.each do |exchange|
  p exchange
  puts '*'*10
end
