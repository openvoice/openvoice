# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Openvoice::Application.initialize!

TROPO_URL = 'http://api.tropo.com/1.0/sessions?action=create&token='
OUTBOUND_MESSAGING_TEMP = "6495a7105bda7c41902027cb67c734c0445cbf5acade80d61b4b9a61b2097bdc62630ea6ef9f0854bb9d96a6"
OUTBOUND_VOICE_TEMP = "c7a69e058363c544bb52e93f69c5db3841d0736b971818dfbf6d5e6c4000526f41b269e9c06238899bd770f5"