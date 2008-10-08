require "rubygems"
require "activesupport"
require "app"
require "model"
require "generators/generator"
require "generators/rails"

@app = App.new(nil)

def generate(*args)
  @app.generate(*args)
end

def route(*args)
  @app.route_args(*args)
end
