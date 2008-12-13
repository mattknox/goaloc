require "erb"

class Merb < Generator
  cattr_accessor :merb_models
  self.merb_models = []

  module MerbModel
    def merb_symname
      '@' + self.s
    end
    
    def merb_plural_symname
      '@' + self.p
    end
    
    def merb_find_string
      "    #{self.merb_symname} = #{self.cs}.get(id)
    raise NotFound unless <%= self.merb_symname -%>"
    end

    def merb_make_new
      self.merb_symname + " #{self.cs}.new" 
    end
  end
  
  def app_name(opts = { })
    name = app.name
    name << "_merb" if opts[:prefix]
    name
  end

  def generate(opts = { })
    app.models.values.each do |m|
      merb_models  << merbify(m)
    end
    
    gen_app
    merb_models.each do |merb_model|
      gen_routes
      gen_migration(merb_model)
      gen_model(merb_model)
      gen_controller(merb_model)
      gen_view(merb_model)
    end
  end

  def merbify(model)
    model.class_eval( "extend MerbModel" )
    model
  end

  def Merb.db_value_name(str)
    #    { "string" => "String", "text"}[str]
    str.capitalize
  end
  
  # gonna get Foy to help with this.
  def gen_app # this is just heinous.  Maybe get rid of it?
    `#{gen_app_string}`
  end

  def gen_app_string
    "merb-gen app #{app.name}"
  end
  
  def gen_routes
    arr = app.routes
    insert_string = arr.map { |a| gen_route(a)}.join("\n") + "\n"
    File.open("#{app_name}/config/router.rb", "w") do |f|
      f.write gen_routes_string
    end
  end

  def gen_routes_string
    arr = app.routes
    insert_string = arr.map { |a| gen_route(a)}.join("\n") + "\n"
    'Merb.logger.info("Compiling routes...")
Merb::Router.prepare do' + "\n"  + 
      insert_string + 
      "end"
  end

  def gen_route(x, pad = "  ")
    if x.is_a? Symbol
      pad + "resources :#{x.to_s}"
    elsif x.is_a? Array
      pad + "resources :#{x.first.to_s} do\n" +
        x[1..-1].map { |y| gen_route(y, pad + "  ")}.join("\n") + "\n" +
        pad + "end"
    end
  end
  
  def gen_migration(model)
  end
  
  def gen_model(model)
    template_str = File.open("#{File.dirname(__FILE__)}/merb/model.rb.erb").read
    ERB.new(template_str).result(binding)
  end

  def gen_controller(model)
  end

  def gen_view(model)
  end
end
