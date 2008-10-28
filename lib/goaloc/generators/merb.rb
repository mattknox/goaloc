require "erb"

class Merb < Generator
  def app_name(opts = { })
    name = app.name
    name << "_merb" if opts[:prefix]
    name
  end

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
