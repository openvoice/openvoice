# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true
config.action_view.cache_template_loading            = true

# See everything in the log (default is :info)
# config.log_level = :debug

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Use a different cache store in production
# config.cache_store = :mem_cache_store

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false

# Enable threaded mode
# config.threadsafe!

SERVER_URL = "http://tropovoice.heroku.com"
OUTBOUND_TOKEN_VOICE = "99044ae8cb64234e97db7cbdf2931d3d5ad0316f62883cc9fd836e9ef89100f31e9314a5e855ea908934f557"
OUTBOUND_TOKEN_MESSAGING = "d24bcbd4e697df4da807f4f99dec0fa0a87201eb903b221e7094ff1d678f74e4df2e641c3928a827ea8dd731"