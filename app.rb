class App
  attr_accessor :name, :models, :routes, :options, :debug

  def initialize(name = nil, options = { })
    self.name = (name or generate_name)
    self.options = options
    self.models = { } # why do I make this a hash, anyway?
    self.routes = []
  end

  def generate_name
    "goaloc_app" + Time.now.strftime("%Y%m%d%H%M%S")
  end
  
  def generate(generator = Rails)
    generator.new(self).generate
  end

  def destroy
    Rails.new.destroy(self)
  end
  
  def route_usage # FIXME: make this only read once.
    f = File.open("doc/route_usage")
    s = f.read
    f.close
    s
  end

  def destroy_model(klass) # TODO: make this also get rid of associations, etc.
    Object.send(:remove_const, klass.to_s.to_sym)
  end
  
  def route_args(*args)  # really want to name this route.  should I rename it?
    if valid_routeset?(args)
      self.routes += args
      args.each do |a|
        build_model(a, nil)
      end
    else
      puts route_usage
    end
  end
  
  def valid_routeset?(args) # TODO: make this less permissive.
    args.is_a? Array and !args.empty?
  end

  def build_model(arg, route)
    if arg.is_a? Symbol
      register_model!(arg, route)
    elsif arg.is_a? Array
      sym = arg.first
      model = (register_model!(sym, route))
      arg[1..-1].each do |a|
        model.has_many(m = build_model(a, (route.to_a << model)))
        models[m.sym_name].belongs_to(model)
      end
      model
    elsif arg.is_a? Hash
      sym = arg[:model]
      register_model!(sym, route)
    end
  end
  
  def register_model!(arg, route)
    self.models[arg] ||= Model.build_and_route(arg, route)
  end
end
