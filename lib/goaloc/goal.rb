# This is the core of goaloc:  the goal object.
# A goal object is intended to be a vertical slice of an MVC app, with information about its model, views,
# controllers, and routes.  It needs to be extended so that it can handle generating plugins/stylesheets/js/etc.
# Generators call a number of methods on goals that allow them to hook into their code generation process and
# customize the output.
class Goal
  attr_reader :name
  attr_accessor :associations, :validations, :fields, :options, :routes, :foreign_keys

  def initialize(name, route = nil)
    @name = name.underscore.singularize   
    self.associations = HashWithIndifferentAccess.new
    self.validations = []
    self.fields = HashWithIndifferentAccess.new
    self.foreign_keys = HashWithIndifferentAccess.new
    self.options = { }
    self.routes = [] # of the form [:classname, [:otherclass, :classname], ...]
    if Object.const_defined? self.cs
      Object.send(:remove_const, self.cs)
    end
    Object.const_set self.cs, self
  end

# TODO: support renaming models
#   # this is a bad thing to do until it actually supports pervasive renaming (assocs, etc.)
#   def name=(name)
#     if Object.const_defined? self.cs and name != self.name
#       Object.send(:remove_const, self.cs)
#     end
#     @name = name
#     Object.const_set self.cs, self
#   end

  # === here are a list of name-ish methods
  # This returns the name of the foreign key used to refer to this goal.
  def foreign_key
    self.name + "_id"
  end

  def s; self.name;  end
  def p; self.name.pluralize; end
  def cs; self.name.camelize.singularize; end
  def cp; self.name.camelize.pluralize; end

  # ensure that this goal has the given route.
  def ensure_route(route)
    unless self.routes.member?(route) or route.blank?
      self.routes << route
    end
  end

  
  # === stuff used to introspect on the goal
  # thanks to Josh Ladieu for this: it's the array of things needed to get to an instance of this class, if there is a unique set.
  # this returns the minimal route to this goal, or nothing, if there is no unambiguous minimal route
  def resource_tuple 
    routelist = self.routes.sort { |x, y| x.length <=> y.length }
    if routelist.length == 1 #TODO: maybe should deal with a case where there's a simplest route that all the others contain.
      routelist.first
    else
      []
    end
  end

  # if a resource has a resource_tuple, and it is not the first element of that
  # tuple, this will return true.
  def nested?
    self.resource_tuple.length > 1
  end

  # enclosing_resource returns the resource that most directly encloses this resource
  def enclosing_resource
    self.resource_tuple[-2]
  end

  # enclosing_resources returns the whole chain of resources up to but not including this one.
  def enclosing_resources
    self.resource_tuple[0..-2]
  end

  def enclosing_goal
    self.enclosing_resource.to_s.singularize.camelize.constantize
  end

  def enclosing_goals
    self.enclosing_resources.map { |r| r.to_s.singularize.camelize.constantize }
  end
  
  def underscore_tuple
    self.resource_tuple.to_a.map { |x| x.to_s.underscore.singularize }
  end

  def ivar_tuple
    self.resource_tuple.to_a.map { |x| "@" + x.to_s.underscore.singularize }
  end

  # this is intended to grab the list of elements needed to populate a form_for,
  # propagated back from the named end_element
  # so for [:users, [:posts, [:comments, :ratings]]] in the rating form it would be:
  # form.comment.post.user, form.comment.post, form.comment, form
  def backvar_tuple(end_element = "form")
    self.resource_tuple[0..-2].map {|sym| sym.to_s.singularize }.reverse.inject([end_element]) {|acc, x| acc.unshift(acc.first + "." + x )}
  end
  
  # this returns the set of resources that are nested under this resource.
  def nested_resources
    APP.goals.reject { |k, v| (v.routes != [(self.resource_tuple + [k.pluralize.to_sym])]) and (v.routes != [(self.resource_tuple + [k.singularize.to_sym])]) } # TODO: see if this can be cleaned up a bit.
  end

  # validations
  def validates(validation_type, field, opts = { })
    self.validations << opts.merge({ :val_type => validation_type, :field => field})
  end

  # === association stuff
  # set a belongs_to association
  def belongs_to(goal, options = { })
    self.foreign_keys[goal.foreign_key] = "references"
    self.validates(:presence_of, goal.foreign_key)
    self.associate(:belongs_to, goal, options)
  end

  # sets a has-many association from this goal to the target goal.  Also sets up a returning belongs_to association
  def has_many(goal, options = { })
    goal.belongs_to(self) unless options[:skip_belongs_to]
    self.associate(:has_many, goal, options)
  end

  # sets up the little-used has-one association, and the returning belongs_to.
  def has_one(goal, options = { })
    goal.belongs_to(self) unless options[:skip_belongs_to]
    self.associate(:has_one, goal, options)
  end

  # this sets a has-many through association, and by default, the reciprocal hmt.
  def hmt(goal, options)
    thru = options[:through]
    self.has_many(thru)
    self.has_many(goal, :through => thru, :skip_belongs_to => true)
    unless options[:bidi] == false
      goal.has_many(thru)
      goal.has_many( self, { :through => thru, :skip_belongs_to => true })
    end
  end

  def associate(assoc_type, goal, options = { })
    assoc_name = options[:assoc_name] || goal.default_assoc_name(assoc_type)
    self.associations[assoc_name] = { :goal => goal, :name => assoc_name, :type => assoc_type }.merge(options)
  end

  def default_assoc_name(assoc_type)
    :has_many == assoc_type ? name.pluralize : name
  end

  # this method adds attributes to the goal, in the format name1:type1 name2:type2.  Type names have unsociable chars like . , - etc. stripped
  def add_attrs(*args)
    if args.is_a? Array and args.length == 1
      args.first.gsub(/[-.,]/, '').split.each do |s|
        name, field_type = s.split(":")
        add_attr(name, field_type)
      end
    end
  end

  def add_attr(name, field_type)
    self.fields[name] = field_type
  end
end
