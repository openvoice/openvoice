# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false

SERVER_URL = "http://web1.tunnlr.com:10790"
OUTBOUND_TOKEN_VOICE = "ac3c8899cac98a49a8af38bac8dcffeb071ea78b27670989282ab28755da9413ecd5b3af59008c8c4c2e99f3"
OUTBOUND_TOKEN_MESSAGING = "6241628991dffb46b219c44e574f01644af865374a1d7c555180232753cc625eb164fa7122da411ed33ac8a2"
