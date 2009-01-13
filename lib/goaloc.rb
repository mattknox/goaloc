$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require "rubygems"
require "activesupport"
require "goaloc/app"
require "goaloc/goal"

module Goaloc
end
