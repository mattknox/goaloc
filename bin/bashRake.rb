#!/usr/bin/env ruby

# Script for bash autocompletion of rake tasks.
#
# Save it somewhere and then add
# complete -C path/to/script -o default rake
# to your ~/.bashrc
#
# This handles rake namespaces and caches the parsing of rake tasks.
#
# Nicholas Seckar <nseckar@gmail.com>
# Saimon Moore <saimon@webtypes.com>
# Seth Plough

rake_file_path = File.join(Dir.pwd, "Rakefile")
exit 0 unless File.file?(rake_file_path)
exit 0 unless /^rake\b/ =~ ENV["COMP_LINE"]
after_match = $'

# cache result of asking rake for its tasks
cache_file_path = File.join(Dir.pwd, ".rake_cache")
if( File.file?(cache_file_path) && (File.mtime(cache_file_path) > File.mtime(rake_file_path)) )
  raw_tasks = File.read(cache_file_path)
else
  raw_tasks = `rake --silent --tasks`
  cache_file = File.new(cache_file_path, "w")
  cache_file << raw_tasks
  cache_file.close
end


task_match = (after_match.empty? || after_match =~ /\s$/) ? nil : after_match.split.last
tasks = raw_tasks.split("\n")[1..-1].collect {|line| line.split[1]}
tasks = tasks.select {|t| /^#{Regexp.escape task_match}/ =~ t} if task_match

# handle namespaces
if task_match =~ /^([-\w:]+:)/
  upto_last_colon = $1
  after_match = $'
  tasks = tasks.collect { |t| (t =~ /^#{Regexp.escape upto_last_colon}([-\w:]+)$/) ? "#{$1}" : t }
end

puts tasks
exit 0