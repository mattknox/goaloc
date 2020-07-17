require 'rake'
require 'rake/testtask'
#require 'rake/rdoctask'
#require 'rcov/rcovtask'
#require 'cucumber/rake/task'
# require 'metric_fu'

# Cucumber::Rake::Task.new(:features) do |t|
#   t.cucumber_opts = "--format pretty"
# end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "goaloc"
    s.summary = %q{ this allows for rapid, console-based generation of merb or rails apps}
    s.email = "matthewknox@gmail.com"
    s.homepage = "http://github.com/mattknox/goaloc"
    s.description =  %q{Generate On A Lot of Crack speeds and extends the early sketching phase of RESTFUL MVC app development }
    s.files = FileList["[A-Z]*.*", "{bin,generators,lib,test,doc,spec}/**/*"]
    s.authors = ["matt knox"]
    s.executables = ["goaloc"]
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

Rake::TestTask.new do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/test_*.rb'
  t.verbose = false
end

# Rake::RDocTask.new do |rdoc|
#   rdoc.rdoc_dir = 'rdoc'
#   rdoc.title    = 'Jeweler'
#   rdoc.options << '--line-numbers' << '--inline-source'
#   rdoc.rdoc_files.include('README*')
#   rdoc.rdoc_files.include('lib/**/*.rb')
# end

# Rcov::RcovTask.new do |t|
#   t.libs << "test"
#   t.verbose = true
# end

#task :default => :rcov
