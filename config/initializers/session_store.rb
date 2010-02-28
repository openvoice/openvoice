# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_tropovoice_session',
  :secret      => 'f15e21e582ebd69167941e4a5422eb06980246877ec058158be89203adcb71b2c4a671eea2b2152e3311cfe61b5c8df5be594d6d9cf7ba61c06b03be5c2db894'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
