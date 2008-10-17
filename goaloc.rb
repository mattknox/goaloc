require "rubygems"
require "activesupport"
require "app"
require "model"
require "generators/generator"
require "generators/rails"

@app = App.new

def generate(*args)
  @app.generate(*args)
end

def route(*args)
  @app.route_args(*args)
end

def add_attrs(h)
  @app.add_attrs(h)
end
