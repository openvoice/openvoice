Openvoice::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_view.debug_rjs             = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  SERVER_URL = "http://web1.tunnlr.com:10790"
  OUTBOUND_TOKEN_VOICE = "ac3c8899cac98a49a8af38bac8dcffeb071ea78b27670989282ab28755da9413ecd5b3af59008c8c4c2e99f3"
  OUTBOUND_TOKEN_MESSAGING = "7c5c3cf9ac55114187ae67e5d3765a3d970604a7879154d65c9dfb9d18053b6244baff37e26e9fd291246207"

end

