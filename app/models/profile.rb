class Profile < ActiveRecord::Base
  belongs_to :user

#  validates_format_of :sip, :with => /(\Asip:)(.*)@(.*)/, :on => :create, :allow_nil => true, :allow_blank => true
#  validates_presence_of :call_url
#  validates_presence_of :voice_token
#  validates_presence_of :messaging_token
  
#  before_create :sanitize_numbers

  after_create :provision_tropo

  def sanitize_numbers
    skype.gsub!(" ", "") unless skype.nil?
  end

  def provision_tropo
    config = YAML.load(File.open('config/tropo.yml'))
    tp = TropoProvisioning.new(config["development"]["user_name"], config["development"]["password"])
    app = tp.create_application({ :name => 'foo',
                            :partition => 'staging',
                            :platform => 'webapi',
                            :voiceUrl => 'http://openvoice.heroku.com/communications/index',
                            :messagingUrl => 'http://openvoice.heroku.com/messagings/create'} )
    # TODO can make better match of last /
    app_id = %r{http://api.tropo.com/provisioning/applications/(.*)}.match(app["href"])[1]
    p app_id
    p tp.exchanges
    app_route = tp.add_route(app_id, { :type => 'did', :prefix => '1407' })
    app_voice_token_route = tp.add_route(app_id, { :type => 'token', :channel => 'voice' })
    app_messaging_token_route = tp.add_route(app_id, { :type => 'token', :channel => 'messaging' })
    p app_did = %r{(.*did/)(.*)}.match(app_route["href"])[2]
    p app_voice_token = %r{(.*token/)(.*)}.match(app_voice_token_route["href"])[2]
    p app_voice_token = %r{(.*token/)(.*)}.match(app_messaging_token_route["href"])[2]
    p tp.routes(app_id)
  end
end
