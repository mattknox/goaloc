require "erb"

class Merb < Generator
  cattr_accessor :merb_models
  self.merb_models = []

  def app_name(opts = { })
    name = app.name
    name << "_merb" if opts[:prefix]
    name
  end

  def generate
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
  # gonna get Foy to help with this.
  def gen_routes
  end
  def gen_migration(model)
  end
  def gen_model(model)
  end
  def gen_controller(model)
  end
  def gen_view(model)
  end
end
