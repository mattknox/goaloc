$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require "rubygems"
require "activesupport"
require "goaloc/app"
require "goaloc/goal"
require "goaloc/generators/generator"
require "goaloc/generators/ruby_generator"
require "goaloc/generators/rails"
module Goaloc
end

APP = @app = App.new

def generate(*args)
  @app.log << "generate #{args.inspect[1..-2]}"
  @app.generator(*args).generate
end

def generator
  @app.generator
end

def route(*args)
  @app.log << "route #{args.inspect[1..-2]}"
  @app.route(*args)
end

def add_attrs(h)
  @app.log << "add_attrs #{h.inspect[1..-2]}"
  @app.add_attrs(h)
end

def showlog
  @app.goaloc_log
end
