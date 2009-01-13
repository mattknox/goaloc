class Goal
  attr_reader :name
  attr_accessor :associations, :validations, :fields, :options, :routes

  def initialize(name)
    @name = name.underscore.singularize   # TODO: support renaming models
    self.associations = { }
    self.validations = []
    self.fields = { }
    self.options = { }
    self.routes = [] # of the form [:classname, [:otherclass, :classname], ...]
  end

  # here are a list of name-ish methods
  def foreign_key
    self.name + "_id"
  end

  def s; self.name;  end
  def p; self.name.pluralize; end
  def cs; self.name.camelize.singularize; end
  def cp; self.name.camelize.pluralize; end

  # association stuff
  def belongs_to(goal)
    self.associations[goal.name] = { :goal => goal, :type => :belongs_to }
    self.fields[goal.foreign_key] = "reference"
  end

  def has_many(goal)
    self.associations[goal.name.pluralize] = { :goal => goal, :type => :has_many }
    goal.belongs_to(self)
  end

  def has_one(goal)
    self.associations[goal.name] = { :goal => goal, :type => :has_one }
    goal.belongs_to(self)
  end

  def associate(assoc_type, goal, options = { })
    assoc_name = options[:assoc_name] || goal.default_assoc_name(assoc_type)
    self.associations[assoc_name] = { :goal => goal, :type => assoc_type }
  end

  def default_assoc_name(assoc_type)
    :has_many == assoc_type ? name.pluralize : name
  end
end
