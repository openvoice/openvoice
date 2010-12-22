require 'rubygems'
require 'yaml'
require 'lib/tropo-provisioning'

config = YAML.load(File.open('examples/config.yml'))

# Create a new provisioning object with your Tropo credentials
provisioning = TropoProvisioning.new(config['tropo']['username'], config['tropo']['password'], :base_uri => 'http://api.voxeo.com/v1')

# Create an account
p provisioning.create_account({ :username   => 'foobar' + rand(10000).to_s, 
                                :first_name => 'Count',
                                :last_name  => 'Dracula',
                                :password   => 'test124',
                                :email      => 'jsgoecke@voxeo.com',
                                :type       => 'temp_developer',
                                #:ip         => '98.207.5.162',
                                :status     => 'active' })


