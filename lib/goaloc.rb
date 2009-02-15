$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require "rubygems"
require "activesupport"
require "goaloc/app"
require "goaloc/goal"
require "goaloc/generators/generator"
require "goaloc/generators/ruby_generator"
require "goaloc/generators/rails"
require "goaloc/generators/merb"
require "goaloc/generators/dm_model"
require "goaloc/generators/ar_model"
module Goaloc
end

APP = @app = App.new

# this causes the app that has been described so far to be generated.  It takes
# the classname (as a constant) of the generator needed.
def generate(*args)
  @app.log << "generate #{args.inspect[1..-2]}"
  @app.generator(*args).generate
end

# this returns a freshly made generator for the app.  
def generator
  @app.generator
end

# this is the primary interface to goaloc.  It allows one to route nested arrays of symbols, generating
# goals, routes, etc., as it goes.  
def route(*args)
  @app.log << "route #{args.inspect[1..-2]}"
  @app.route(*args)
end

# add_attrs takes in a hash of names and strings denoting fields, of this form:
# :comments => "body:text", 'post' => "score:integer title:string" etc.
def add_attrs(h)
  @app.log << "add_attrs #{h.inspect[1..-2]}"
  @app.add_attrs(h)
end

def showlog
  @app.goaloc_log
end

def reset
  @app = App.new
end

def models(*args)
  args.map { |x| @app.fetch_or_create_goal(x) }
end
