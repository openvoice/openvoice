# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{jquery-rails}
  s.version = "0.2.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6") if s.respond_to? :required_rubygems_version=
  s.authors = ["André Arko"]
  s.date = %q{2010-12-01}
  s.description = %q{This gem provides a Rails generator to install jQuery and the jQuery-ujs driver into your Rails 3 application, and then have them included automatically instead of Prototype.}
  s.email = ["andre@arko.net"]
  s.files = [".gitignore", "CHANGELOG.md", "Gemfile", "Gemfile.lock", "README.md", "Rakefile", "jquery-rails.gemspec", "lib/generators/jquery/install/install_generator.rb", "lib/jquery-rails.rb", "lib/jquery-rails/assert_select_jquery.rb", "lib/jquery-rails/version.rb", "spec/lib/generators/jquery/install_generator_spec.rb", "spec/lib/jquery-rails_spec.rb", "spec/spec_helper.rb", "spec/support/custom_app/.gitignore", "spec/support/custom_app/Gemfile", "spec/support/custom_app/config.ru", "spec/support/custom_app/config/application.rb", "spec/support/custom_app/config/boot.rb", "spec/support/custom_app/config/database.yml", "spec/support/custom_app/config/environment.rb", "spec/support/custom_app/config/environments/development.rb", "spec/support/custom_app/config/environments/production.rb", "spec/support/custom_app/config/environments/test.rb", "spec/support/custom_app/config/routes.rb", "spec/support/custom_app/script/rails", "spec/support/default_app/.gitignore", "spec/support/default_app/Gemfile", "spec/support/default_app/config.ru", "spec/support/default_app/config/application.rb", "spec/support/default_app/config/boot.rb", "spec/support/default_app/config/database.yml", "spec/support/default_app/config/environment.rb", "spec/support/default_app/config/environments/development.rb", "spec/support/default_app/config/environments/production.rb", "spec/support/default_app/config/environments/test.rb", "spec/support/default_app/config/routes.rb", "spec/support/default_app/public/javascripts/application.js", "spec/support/default_app/public/javascripts/controls.js", "spec/support/default_app/public/javascripts/dragdrop.js", "spec/support/default_app/public/javascripts/effects.js", "spec/support/default_app/public/javascripts/jquery.js", "spec/support/default_app/public/javascripts/jquery.min.js", "spec/support/default_app/public/javascripts/prototype.js", "spec/support/default_app/public/javascripts/rails.js", "spec/support/default_app/script/rails"]
  s.homepage = %q{http://rubygems.org/gems/jquery-rails}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{jquery-rails}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Use jQuery with Rails 3}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rails>, ["~> 3.0"])
      s.add_runtime_dependency(%q<thor>, ["~> 0.14.4"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_development_dependency(%q<rspec>, ["~> 1.3"])
      s.add_development_dependency(%q<webmock>, ["~> 1.4.0"])
    else
      s.add_dependency(%q<rails>, ["~> 3.0"])
      s.add_dependency(%q<thor>, ["~> 0.14.4"])
      s.add_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_dependency(%q<rspec>, ["~> 1.3"])
      s.add_dependency(%q<webmock>, ["~> 1.4.0"])
    end
  else
    s.add_dependency(%q<rails>, ["~> 3.0"])
    s.add_dependency(%q<thor>, ["~> 0.14.4"])
    s.add_dependency(%q<bundler>, ["~> 1.0.0"])
    s.add_dependency(%q<rspec>, ["~> 1.3"])
    s.add_dependency(%q<webmock>, ["~> 1.4.0"])
  end
end
