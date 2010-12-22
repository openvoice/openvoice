require 'spec/helper'


describe "Testing FSR module loading methods" do
  # When you add applications  you must modify the expected apps_loaded behavior
  it "Loads all applications" do
    all_apps = [:play_and_get_digits, :uuid_dump, :uuid_setvar, :uuid_getvar, :read, :set, :transfer, :speak, :fs_sleep, :playback, :answer, :fifo, :bridge, :hangup, :conference, :fs_break, :log, :limit, :bind_meta_app, :execute_app]
    # Add any apps which will load to this set
    apps_loaded = FSR.load_all_applications
    apps_loaded.kind_of?(Array).should == true
    all_apps.each do |app|
      apps_loaded.delete(app).should == app
    end
    apps_loaded.size.should == 0
  end

  # When you add commands  you must modify the expected cmds_loaded behavior
  it "Loads all commands" do
    all_commands = [:uuid_dump, :originate, :sofia, :fsctl, :sofia_contact, :status, :calls, :call_center, :channels, :enum] # If you add a command add it to this set
    cmds_loaded = FSR.load_all_commands
    cmds_loaded.kind_of?(Array).should == true
    all_commands.each do |cmd|
      cmds_loaded.delete(cmd).should == cmd
    end
    cmds_loaded.size.should == 0
  end
end
