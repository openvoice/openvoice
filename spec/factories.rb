require 'factory_girl'
require 'factory_girl_rails'
require 'authlogic'

Factory.define :user do |u|
  u.id 1
  u.login "zlu"
  u.email "zlu@exmaple.com"
  u.password_salt(Authlogic::Random.hex_token)
  u.crypted_password "password"
  u.password "password"
  u.password_confirmation "password"
  u.persistence_token Authlogic::Random.hex_token
  u.single_access_token Authlogic::Random.friendly_token
  u.perishable_token Authlogic::Random.friendly_token
  
end

Factory.define :profile do |p|
  p.id 1
  p.voice "14151112222"
  p.call_url "http://fakeurl.com"
  p.voice_token "faketoken"
  p.messaging_token "faketoken"
end

Factory.define :incoming_call do |ic|
  ic.user_id 1
end

Factory.define :outgoing_call do |oc|
  oc.user_id 1
end