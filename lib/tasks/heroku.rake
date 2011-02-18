namespace :heroku do
  desc "deploy code to heroku"
  task :deploy do
    system!('heroku maintenance:on')
    system!('git push')
    system!('heroku rake db:migrate')
    system!('heroku restart')
    system!('heroku maintenance:off')
  end

  def system!(cmd)
    puts "Running: #{cmd}"
    system(cmd) or raise "Command failed: #{cmd}"
  end
end