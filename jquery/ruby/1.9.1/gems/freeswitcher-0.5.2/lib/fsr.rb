require 'socket'
require 'pathname'
require 'pp'

# Author::    TJ Vanderpoel (mailto:bougy.man@gmail.com)
# Copyright:: Copyright (c) 2009 The Rubyists (Jayson Vaughn, TJ Vanderpoel, Michael Fellinger, Kevin Berry)
# License::   Distributes under the terms of the MIT License http://www.opensource.org/licenses/mit-license.php

## This module declares the namespace under which the freeswitcher framework
## Any constants will be defined here, as well as methods for loading commands and applications
class Pathname
  def /(other)
    join(other.to_s)
  end
end
module FSR
  # Global configuration options
  FS_INSTALL_PATHS = ["/usr/local/freeswitch", "/opt/freeswitch", "/usr/freeswitch", "/home/freeswitch/freeswitch"]
  DEFAULT_CALLER_ID_NUMBER = '8675309'
  DEFAULT_CALLER_ID_NAME   = "FSR"

  #  attempt to require log4r.  
  #  if log4r is not available, load logger from stdlib
  begin
    require 'log4r'
    Log = Log4r::Logger.new('FSR')
    Log.outputters = Log4r::Outputter.stdout
    Log.level = Log4r::INFO
  rescue LoadError
    $stderr.puts "No log4r found, falling back to standard ruby library Logger"
    require 'logger'
    Log = Logger.new(STDOUT)
    Log.level = Logger::INFO
  end

  ROOT = Pathname(__FILE__).dirname.expand_path.freeze
  $LOAD_PATH.unshift(FSR::ROOT.to_s)

  FSR_ROOT = Pathname(__FILE__).join("..").dirname.expand_path.freeze
  $LOAD_PATH.unshift(FSR::FSR_ROOT.to_s)

  # Load all FSR::Cmd classes
  def self.load_all_commands(retrying = false)
    require 'fsr/command_socket'
    load_all_applications
    Cmd.load_all
  end
  
  # Load all FSR::App classes
  def self.load_all_applications
    require "fsr/app"
    App.load_all
  end

  # Method to start EM for Outbound Event Socket
  def self.start_oes!(klass, args = {})
    port = args.delete(:port) || "8084"
    host = args.delete(:host) || "localhost"
    EM.run do
      EventMachine::start_server(host, port, klass, args)
      FSR::Log.info "*** FreeSWITCHer Outbound EventSocket Listener on #{host}:#{port} ***"
      FSR::Log.info "*** http://code.rubyists.com/projects/fs"
    end
  end
  
  # Method to start EM for Inbound Event Socket
  # @see FSR::Listener::Inbound
  # @param [FSR::Listener::Inbound] klass An Inbound Listener class, to be started by EM.run
  # @param [::Hash] args A hash of options, may contain
  #                       <tt>:host [String]</tt> The host/ip to bind to (Default: "localhost") 
  #                       <tt>:port [Integer]</tt> the port to listen on (Default: 8021)
  def self.start_ies!(klass, args = {})
    args[:port] ||= 8021
    args[:host] ||= "localhost"
    EM.run do
      EventMachine::connect(args[:host], args[:port], klass, args)
      FSR::Log.info "*** FreeSWITCHer Inbound EventSocket Listener connected to #{args[:host]}:#{args[:port]} ***"
      FSR::Log.info "*** http://code.rubyists.com/projects/fs"
    end
  end


  # Find the FreeSWITCH install path if running FSR on a local box with FreeSWITCH installed.
  # This will enable sqlite db access
  def self.find_freeswitch_install
    good_path = FS_INSTALL_PATHS.find do |fs_path|
      FSR::Log.warn("#{fs_path} is not a directory!") if File.exists?(fs_path) && !File.directory?(fs_path)
      FSR::Log.warn("#{fs_path} is not readable by this user!") if File.exists?(fs_path) && !File.readable?(fs_path)
      Dir["#{fs_path}/{conf,db}/"].size == 2 ? fs_path.to_s : nil
    end
    FSR::Log.warn("No FreeSWITCH install found, database and configuration functionality disabled") if  good_path.nil?
    good_path
  end

  FS_ROOT = find_freeswitch_install # FreeSWITCH $${base_dir}

  if FS_ROOT
    FS_CONFIG_PATH = (FS_ROOT + 'conf').freeze # FreeSWITCH conf dir
    FS_DB_PATH = (FS_ROOT + 'db').freeze       # FreeSWITCH db dir
  else
    FS_CONFIG_PATH = FS_DB_PATH = nil
  end
end
require "fsr/version"

