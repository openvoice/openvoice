desc "update version.rb"
task :reversion do
  File.open("lib/fsr/version.rb", 'w+') do |file|
    file.puts("module FSR")
    file.puts('  VERSION = %p' % GEMSPEC.version.to_s)
    file.puts('end')
  end
end
