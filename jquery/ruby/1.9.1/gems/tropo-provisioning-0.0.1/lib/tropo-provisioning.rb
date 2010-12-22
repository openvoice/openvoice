$: << File.expand_path(File.dirname(__FILE__))
%w(net/http uri active_support/json active_support/inflector hashie tropo-provisioning/tropo-provisioning).each { |lib| require lib }
