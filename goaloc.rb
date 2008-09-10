require "rubygems"
require "activesupport"

class App
  attr_accessor :name, :models, :routes, :options, :debug1

  def initialize
    self.models = { }
    self.routes = []
  end
  
  def generate(target = :rails, backend = :default)
    puts models
    puts "generate got called!"
  end
  
  def route(*args)
    if args.empty?
      puts """to get the url '/blogs/1/posts/1/comments' => route [ :blogs, [:posts, :comments]]
map.resources :foo
map.resources :bar
map.resources :baz    => route :foo, :bar, :baz

map.resources :users do |user
  user.resources :blogs
  user.resources :projects
end
=> route [:users, :blogs, :projects]

"""
    else
      defroute(*args)
    end
  end

  def valid_route?(args)
    args.is_a? Array
  end

  def defroute(*args)
    if valid_route?(args)
      self.routes += args
      args.each do |a|
        build_model(a)
      end
    else
      puts "invalid route"
    end
  end

  def build_model(arg)
    # FIXME: if given something like [:user, [:post, [:user]]], the rightmost instance will define the user.
    assocs = { }
    if arg.is_a? Symbol
      name = arg
    elsif arg.is_a? Array
      name = arg.first
      arg[1..-1].each do |a|
        am = build_model(a)
        if am
          assocs[am.name] = { :classname => am.name, :type => :has_many}
          key = (name.to_s.singularize + "_id").to_sym
          am.fields[key] = :int
        end
      end
    end
    m = (self.models[name] || Model.new(name))
    assocs.each do |k, v|
      m.has_many(self.models[k])
      self.models[k].belongs_to(m)
    end
    self.models[name] = m
    m
  end
end

class Model
  attr_accessor :name, :associations, :fields
  
  def initialize(name)
    self.name = name
    self.associations = { }
    self.fields = { }
  end

  def classname
    self.name.to_s.singularize.capitalize
  end

  def belongs_to(m)
    associate(:belongs_to, m)
  end

  def has_many(m)
    associate(:has_many, m)
  end

  def associate(meth, model)
    self.associations[model.classname] = { :classname => model.classname, :type => meth}    
  end
end

@app = App.new

def generate(*args)
  @app.generate(*args)
end

def route(*args)
  @app.route(*args)
end

route :users, [:posts, :comments]
