desc 'install all possible dependencies'
task :setup => :gem_installer do
  GemInstaller.new do
    # core
    gem 'eventmachine'

    # doc
    gem 'yard'

    setup
  end
end

desc 'install all possible dependencies'
task :setup_spec => :setup do
  GemInstaller.new do
    # spec
    gem 'bacon'

    gem 'tmm1-em-spec', :lib => "em/spec"
    
    setup
  end
end
