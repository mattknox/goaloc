class App
  attr_accessor :name, :routes, :goals, :options

  def initialize(name = nil)
    self.name = (name or generate_name)
    self.routes = []
    self.goals = { }
  end

  def generate_name
    "goaloc_app" + Time.now.strftime("%Y%m%d%H%M%S")
  end

  def route(*args)
    if valid_routeset?(args)
      self.routes += args.map { |elt| route_elt(elt, []) }
    end
  end

  def route_elt(arg, route_prefix)
    if arg.is_a? Symbol
      goal_for_sym(arg, route_prefix)
      arg
    elsif arg.is_a? Array
      res = [route_elt(arg.first, route_prefix)]
      arg[1..-1].each do |elt|
        res << route_elt(elt, route_prefix)
      end
      res
    end
  end

  def goal_for_sym(sym, route_prefix)
    name = sym.to_s.singularize
    self.goals[name] ||= Goal.new(name)
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
end

#   def add_attrs(h)
#     h.map {  |k, v| k.to_s.singularize.camelize.constantize.add_attrs v rescue nil }
#   end
  
#   def build_model(arg, r)
#     if arg.is_a? Symbol
#       register_model!(arg, r)
#     elsif arg.is_a? Array
#       sym = arg.first
#       model = (register_model!(sym, r))
#       arg[1..-1].each do |a|
#         m = build_model(a, (r.to_a.clone << model))
#         model.has_many(m)
#       end
#       model
#     elsif arg.is_a? Hash
#       sym = arg[:class]
#       model = register_model!(sym, r)
#       thru = arg[:through]
#       thru_model = register_model!(thru, r) if thru
#       model.handle_hash(arg)
#     end
#   end

#   def build_model_from_hash(m, h, r)
#     if h.has_key?(:through)
#       m.hmt(h)
#     end
#   end
  
#   def register_model!(arg, r)
#     Model.build_and_route(arg, r)
#   end

#   def goaloc_log
#     gen = []
#     out = log.clone
#     out.unshift "@app.name = #{self.name}" unless self.name.to_s.match(/goaloc_app20/)
#     gen = [out.pop] if out.last.to_s.match(/^generate/)
#     out << ("route " + self.routes.inspect[1..-2]) unless routes.empty?
#     self.models.each do |key, model|
#       model.associations.each do |name, assoc|
#         if assoc.has_key?(:through)
#           out << "#{model}.hmt({ :class => #{assoc[:class]}, :through => #{assoc[:through]})"
#         else
#           out << "#{model.to_s}.#{assoc[:type]}(#{assoc[:model].to_s})"
#         end
#       end
#     end
#     out + gen
#   end
# end
