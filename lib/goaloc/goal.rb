class Goal
  attr_reader :name
  attr_accessor :associations, :validations, :fields, :options, :routes, :foreign_keys

  def initialize(name, route = [])
    @name = name.underscore.singularize   # TODO: support renaming models
    self.associations = HashWithIndifferentAccess.new
    self.validations = []
    self.fields = HashWithIndifferentAccess.new
    self.foreign_keys = HashWithIndifferentAccess.new
    self.options = { }
    self.routes = [] # of the form [:classname, [:otherclass, :classname], ...]
    Object.const_set self.cs, self
  end

  # here are a list of name-ish methods
  def foreign_key
    self.name + "_id"
  end

  def s; self.name;  end
  def p; self.name.pluralize; end
  def cs; self.name.camelize.singularize; end
  def cp; self.name.camelize.pluralize; end

  # stuff used to introspect on the goal
  # thanks to Josh Ladieu for this: it's the array of things needed to get to an instance of this class, if there is a unique set.
  def resource_tuple # this returns the minimal route to this goal, or nothing, if there is no unambiguous minimal route
    routelist = self.routes.sort { |x, y| x.length <=> y.length }
    if routelist.length == 1 #TODO: maybe should deal with a case where there's a simplest route that all the others contain.
      routelist.first
    else
      []
    end
  end

  def nested?
    self.resource_tuple.length > 1
  end

  def underscore_tuple
    self.resource_tuple.to_a.map { |x| x.to_s.underscore.singularize }
  end

  def ivar_tuple
    self.resource_tuple.to_a.map { |x| "@" + x.to_s.underscore.singularize }
  end

  def backvar_tuple(end_element = "form")
    # this is intended to grab the list of elements needed to populate a form_for,
    # propagated back from the named end_element
    # so for [:users, [:posts, [:comments, :ratings]]] in the rating form it would be:
    # form.comment.post.user, form.comment.post, form.comment, form
    self.resource_tuple[0..-2].map {|sym| sym.to_s.singularize }.reverse.inject([end_element]) {|acc, x| acc.unshift(acc.first + "." + x )}
  end
  
  def nested_resources
    APP.goals.reject { |k, v| v.routes != [(self.resource_tuple + [k.pluralize.to_sym])] } # TODO: make this work with singular resources
  end

  # validations
  def validates(validation_type, field, opts = { })
    self.validations << opts.merge({ :val_type => validation_type, :field => field})
  end

  # association stuff
  def belongs_to(goal, options = { })
#    self.fields[goal.foreign_key] = "references"
    self.foreign_keys[goal.foreign_key] = "references"
    self.validates(:presence_of, goal.foreign_key)
    self.associate(:belongs_to, goal, options)
  end

  def has_many(goal, options = { })
    goal.belongs_to(self) unless options[:skip_belongs_to]
    self.associate(:has_many, goal, options)
  end

  def has_one(goal, options = { })
    goal.belongs_to(self) unless options[:skip_belongs_to]
    self.associate(:has_one, goal, options)
  end

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

  def add_attrs(*args)
    if args.is_a? Array and args.length == 1
      args.first.split.each do |s|
        name, field_type = s.split(":")
        add_attr(name, field_type)
      end
    end
  end

  def add_attr(name, field_type)
    self.fields[name] = field_type
  end
end
