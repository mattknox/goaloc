class App
  attr_accessor :name, :routes, :goals, :options, :log

  def initialize(name = nil)
    self.name = (name or generate_name)
    self.routes = []
    self.log = []
    self.goals = HashWithIndifferentAccess.new
  end

  def generate_name
    "goaloc_app" + Time.now.strftime("%Y%m%d%H%M%S")
  end

  def route(*args)
    if valid_routeset?(args)
      self.routes += args # FIXME: make this so that it just maps over args again
      args.map { |elt| route_elt(elt, []) }
    end
  end

  def route_elt(arg, route_prefix)
    if arg.is_a? Symbol
      goal_for_sym(arg, route_prefix.clone << arg)
    elsif arg.is_a? Array
      base = route_elt(arg.first, route_prefix)
      res = [base]
      arg[1..-1].each do |elt|
        goal = route_elt(elt, route_prefix.clone << arg.first)
        if plural?(elt)
          base.has_many(goal)
        else
          base.has_one(goal)
        end
        res << goal
      end
      res
    end
  end

  def goal_for_sym(sym, route_prefix)
    name = sym.to_s.singularize
    self.goals[name] ||= Goal.new(name, route_prefix)
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

  def add_attrs(h)
    h.map {  |k, v| self.goals[k.to_s.singularize].add_attrs v rescue nil }
  end
  
  def plural?(sym)
    sym.to_s.pluralize == sym.to_s
  end

  def goaloc_log
    gen = []
    out = log.clone
    out.unshift "@app.name = #{self.name}" unless self.name.to_s.match(/goaloc_app20/)
    gen = [out.pop] if out.last.to_s.match(/^generate/)
    out << ("route " + self.routes.inspect[1..-2]) unless routes.empty?
    self.goals.each do |key, goal|
      goal.associations.each do |name, assoc|
        if assoc.has_key?(:through)
          out << "#{goal}.hmt({ :class => #{assoc[:class]}, :through => #{assoc[:through]})"
        else
          out << "#{goal.to_s}.#{assoc[:type]}(#{assoc[:goal].name})"
        end
      end
    end
    out + gen
  end
end
