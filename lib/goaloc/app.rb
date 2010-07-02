# Author::    Matt Knox  (mailto:matthewknox@gmail.com)
# Copyright:: Copyright (c) 2009 Matt Knox
# License::   Distributes under the same terms as Ruby
#
# This is Generate on a Lot of Crack, which aims to speed and extend the initial definition of a rails app.
# It was motivated by the fact that to make a nested resource (ie, to get  /posts/1/comments to resolve),
# one must specify the relation between post and comment in 4 places:  the routes, the migration, and in
# both models.  That's silly, and not so DRY.  Enter GoaLoC, and the "blog in 15 minutes" talk essentially
# reduces to:
#   goaloc
#   >> @app.name = "myblog"
#   >> route [:posts, :comments]
#   >> add_attrs :posts => "body:text title:string", :comments => "body:text"
#   >> generate
#
# generate presently only knows how to make rails apps, and part of merb apps, but in principle, any
# REST-centric MVC app could be targeted comfortably, and even PHP apps could be done.

class App
  attr_accessor :name, :routes, :goals, :options, :log

  def initialize(name = nil)
    self.name = (name or generate_name)
    self.routes = []
    self.log = []
    self.goals = HashWithIndifferentAccess.new
  end

  # take in any number of ruby expressions, (presently limited to symbols and nested arrays of symbols),
  # and define those expressions as valid routes.  If the routed resources don't exist, define them,
  # and the relations with other resources implied by the route expression.  For instance, route :posts
  # implies that you'll want a model Post.  More interestingly,
  #   route [:posts, :comments, :wiki]
  # implies that there must be Post, Comment, and Wiki models, and that a Post has many comments and
  # has one wiki.
  def route(*args)
    if valid_routeset?(args)
      self.routes += args.map { |elt| route_elt(elt, []) }
    end
  end

  # this returns the goal (resource generated by goaloc) named by a given string or symbol.  Goal names
  # are always singular, so it allows for singular or plural variants of anything that responds to #to_s
  # as a degenerate case, if one passes in a goal, it will merely be returned.
  def fetch_or_create_goal(x)
    fetch_goal(x) or create_goal(x)
  end

  def fetch_goal(x) # should I perhaps make Post.to_s == "Post" or some such?  that would make this method tiny...
    if x.is_a? Goal
      x
    else
      self.goals[x.to_s.singularize.underscore]
    end
  end

  def create_goal(x)
    name = x.to_s.singularize.underscore
    self.goals[name] ||= Goal.new(name) # dynamic var would be nice here.
  end

  # add_attrs takes in a hash of symbol => string pairs, and attaches to the goal named by the key the
  # attributes named in the string.  For example:
  #   add_attrs :posts => "body:text title:string", :ratings => "score:integer"
  # adds an integer field named score to Rating, a text field called body to Post, and a string field
  # called title to Post.
  def add_attrs(h)
    h.map {  |k, v| self.goals[k.to_s.singularize].add_attrs v rescue nil }
  end

  # Returns a generator for the given target output format.  Currently Rails and Merb are supported.
  def generator(target = Rails)
    generator = Generator.build(self, target)
  end

  #gets a generator and calls the generate method on it.
  def generate(*args)
    generator(*args).generate
  end

  # generate a log of the commands that goaloc would have to recieve to reach its current state.
  # this currently double-counts some commands, and might miss others, for instance if one got
  # a goal object and poked at it's internal state directly.
  def goaloc_log
    gen = []
    out = log.clone
    out.unshift "@app.name = '#{self.name}'" unless self.name.to_s.match(/goaloc_app20/)
    gen = [out.pop] if out.last.to_s.match(/^generate/)
    out << ("route " + self.routes.inspect[1..-2]) unless routes.empty?
    self.goals.each do |key, goal|
      goal.associations.each do |name, assoc|
        if assoc.has_key?(:through)
          out << "#{goal.cs}.hmt({ :class => #{assoc[:class]}, :through => #{assoc[:through].cs})"
        else
          out << "#{goal.cs}.#{assoc[:type]}(#{assoc[:goal].cs})"
        end
      end
    end
    out + gen
  end

  private
  def route_elt(arg, route_prefix)
    if arg.is_a? Symbol
      goal_for_sym(arg, route_prefix.clone) and arg
    elsif arg.is_a? Array
      base = goal_for_sym(route_elt(arg.first, route_prefix), route_prefix.clone)
      res = [arg.first]
      arg[1..-1].each do |elt|
        route_frag = route_elt(elt, route_prefix.clone << arg.first)
        goal = goal_for_sym(( route_frag.is_a?(Array) ? route_frag.first : route_frag ), (route_prefix.clone << arg.first))
        if plural?(elt)
          base.has_many(goal)
        else
          base.has_one(goal)
        end
        res << route_frag
      end
      res
    end
  end

  def generate_name
    "goaloc_app" + Time.now.strftime("%Y%m%d%H%M%S")
  end

  def goal_for_sym(x, route_prefix)  # should refactor this to separate the route and the grabbing the goal.
    goal = fetch_or_create_goal(x)
    goal.ensure_route(route_prefix.clone << x)
    goal
  end

  def valid_routeset?(arg)
    arg.is_a?(Symbol) or
      valid_routeset_array?(arg)
  end

  def valid_routeset_array?(arg)
    arg.is_a? Array and
      !arg.empty? and
      arg.all? { |x| valid_routeset?(x) }
  end

  def plural?(sym)
    sym.to_s.pluralize == sym.to_s
  end
end
