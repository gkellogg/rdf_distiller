# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_rdfa_service_session',
  :secret      => '8c47d464c24287d4f568e250bb898cb5f9b8c74f47ed9f3999679b0f64f94f5c0a4fe9db13a8d08ac0608610a9d82cc6c603f382b3d2b2e68da19b05538bcc37'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
