begin
  require 'bacon'
rescue LoadError
  begin
    require "rubygems"
    require "bacon"
  rescue LoadError
    puts <<-EOS
  To run these tests you must install bacon.
  Quick and easy install for gem:
      gem install bacon
  EOS
    exit(0)
  end
end

Bacon.summary_on_exit

require File.expand_path(File.join(File.dirname(__FILE__), '../lib/fsr'))
