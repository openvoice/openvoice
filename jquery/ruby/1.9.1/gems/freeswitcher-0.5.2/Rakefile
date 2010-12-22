require 'rake/clean'
require "rubygems"
require "./lib/fsr"
require "pathname"

PROJECT_COPYRIGHT = Pathname(__FILE__).dirname.join("License.txt").read
PROJECT_README = Pathname(__FILE__).dirname.join("README").expand_path.to_s
PROJECT_FILES  = %x{git ls-files}.split
RELEASE_FILES  = PROJECT_FILES.reject { |f| f.match(/^(?:contrib)(?:\/|$)/) }
GEM_FILES      = RELEASE_FILES.reject { |f| f.match(/^(?:spec)(?:\/|$)/) }
PROJECT_SPECS  = (RELEASE_FILES - GEM_FILES).reject { |d| d.match(/(?:helper.rb)$/) }
GEM_FILES << "spec/helper.rb" if Pathname("spec/helper.rb").file?
GEM_FILES << "spec/fsr_listener_helper.rb" if Pathname("spec/helper.rb").file?


GEMSPEC = Gem::Specification.new do |spec|
  spec.name = "freeswitcher"
  spec.version = (ENV["FSR_VERSION"] || FSR::VERSION).dup
  spec.summary = 'A library for interacting with the "FreeSWITCH":http://freeswitch.org telephony platform'
  spec.authors = ["Jayson Vaughn", "Michael Fellinger", "Kevin Berry", "TJ Vanderpoel"]
  spec.email = "FreeSWITCHeR@rubyists.com"
  spec.homepage = "http://code.rubyists.com/projects/fs"
  spec.add_dependency "eventmachine"
  
  spec.files = GEM_FILES
  spec.test_files = PROJECT_SPECS
  spec.require_path = "lib"

  spec.description = spec.summary
  spec.rubyforge_project = "freeswitcher"
  spec.post_install_message = File.read(PROJECT_README)
end

import(*Dir['tasks/*rake'])

task :default => :bacon
