$: << File.expand_path(File.dirname(__FILE__))
%w(uri json hashie time tropo-webapi-ruby/tropo-webapi-ruby-helpers tropo-webapi-ruby/tropo-webapi-ruby).each { |lib| require lib }

# Add the instance_exec method to the object class for Ruby 1.8.6 support
require 'tropo-webapi-ruby/object_patch' if RUBY_VERSION == '1.8.6'