$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require "rubygems"
require "activesupport"
require "goaloc/app"
require "goaloc/model"
require "goaloc/generators/generator"
require "goaloc/generators/rails"
require "goaloc/generators/merb"

module Goaloc
end

@app = App.new
APP = @app

def generate(*args)
  @app.generate(*args)
end

def route(*args)
  @app.route(*args)
end

def add_attrs(h)
  @app.add_attrs(h)
end
