require 'rubygems'
require 'lib/tropo-provisioning'

config = YAML.load(File.open('examples/config.yml'))
app_details = YAML.load(File.open("examples/#{config['filename']}"))

# Create a new provisioning object with your Tropo credentials
provisioning = TropoProvisioning.new(config['tropo']['username'], config['tropo']['password'])

# First, get the application in question
application = provisioning.application(app_details.application_id)

# Set the name we want to change to
application['name'] = 'My Awesome App'

# Then create the application you would like to
p provisioning.update_application(app_details.application_id, application)