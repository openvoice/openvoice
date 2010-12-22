desc 'Generate YARD documentation'
task :yard => :clean do
  sh("yardoc -o ydoc --protected -r #{PROJECT_README}")
end
