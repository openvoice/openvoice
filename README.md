OpenVoice
====

<a href="http://github.com/openvoice">OpenVoice</a> is a GoogleVoice clone developed in Rails.  There are some notable
differences:

* It uses <a href="http://tropo.com">Tropo</a> to handle actual voice, SMS, and IM.  It also adding support to Asterisk
and FreeSwitch.
* It provides Skype, SIP endpoints.
* It supports in-browser flash phone.
* Some of the functions are:
** Phone number provision: USA only for now
** Caller screen, caller announcement, call log
** Visual Voicemail and voicemail transcription
** API support for call control and SMS
** Android client available
** Free

Support
----
Please join our discussion group on Google Groups.
* Group name: openvoice
* Group home page: http://groups.google.com/group/myopenvoice
* Group email address myopenvoice@googlegroups.com
* Twitter: openvoice

There are two ways to use OpenVoice:
----
1. Use http://openvoice.heroku.com

First go to http://openvoice.heroku.com/users/new to create a new login.
Then click on profile link and note that you have a voice number provisioned.  This is your openvoice number.
Then click on "phone numbers" link and add some number you want to link to your openvoice number.
Forward: check this box if you want the call to be forwarded to this number when someone calls your openvoice number.
Default: only check one of these.  This number is used for outbound calls.  When you call someone, it will first ring
this number.  Once your pick up the phone, it will ring the destination number.

Please keep in mind that this openvoice server is under active developement thus in no way stable.  If you want stability,
deploy the code on your own server.

2. Self-hosted

First you need to create a tropo application.  Go to tropo.com and sign up for a free developer's account.
Create a tropo application and make it look like this:
"tropo application setup":http://idisk.me.com/zlu/Public/Pictures/Skitch/Tropo.com-20100609-082358.jpg
Url for voice (replace server to your own domain)
http://openvoice.heroku.com/communications/index?format=json
And the url for messaging is (replace server to your own domain):
http://openvoice.heroku.com/messagings/create?format=json

export the following environment variables for shell (in .bashrc or .profile)
export TROPO_APP=your_tropo_applicaton_id
export TROPO_USER=your_tropo_user_name
export TROPO_PASS=your_tropo_password
export FS_HOST=your_freeswitch_server
export FS_HOST_IP=your_freeswitch_ip
export FS_PORT=your_freeswitch_port
export FS_PASSWORD=your_freeswitch_password


if you are deploying to heroku, use the following instruction to define config vars:
http://docs.heroku.com/config-vars

* To find out the tropo_app_id:
Go to this url in your browser:
http://your_tropo_user_name:your_tropo_password@api.tropo.com/provisioning/applications
Accept warnings and you should see a list of all your tropo apps in json.
The number at then end of href is the app_id.  I know this approach is less ideal, but in the future tropo will
display app_id in web ui.  Also I plan to add tropo app provision in OV.

Next edit development.rb and production.rb
SERVER_URL = your_domain
OUTBOUND_TOKEN_VOICE = your_tropo_voice_token
OUTBOUND_TOKEN_MESSAGING = your_tropo_messaging_token

Start ov server and create a new user.  Now go to
Then click on profile link and note that you have a voice number provisioned.  This is your openvoice number.
Then click on "phone numbers" link and add some number you want to link to your openvoice number.
Forward: check this box if you want the call to be forwarded to this number when someone calls your openvoice number.
Default: only check one of these.  This number is used for outbound calls.  When you call someone, it will first ring
this number.  Once your pick up the phone, it will ring the destination number.

Development Environment Setup
----

Create a tropo app first and get your own phone numbers and IMs
Clone this project and start the rails server on your local machine
Highly recommend use rake tunnel:tunnel:start to reverse tunnel to your local machine for faster development.
You can either setup your own reverse ssh tunnel or get one from tunnlr.com.
Please don't use my tunnlr credential.

Bugs
----
If you find bugs, please log them in the issues section on github.

