require 'factory_girl'
require 'factory_girl_rails'
require 'authlogic'

Factory.define :user do |u|
  u.id 1
  u.login "zlu"
  u.email "zlu@exmaple.com"
  u.password_salt(salt = Authlogic::Random.hex_token)
  u.crypted_password "password"
  u.password "password"
  u.password_confirmation "password"
#  u.crypted_password Authlogic::CryptoProviders::Sha512.encrypt("password" + salt)
  u.persistence_token Authlogic::Random.hex_token
  u.single_access_token Authlogic::Random.friendly_token
  u.perishable_token Authlogic::Random.friendly_token
end
