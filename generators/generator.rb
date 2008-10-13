class Generator
  attr_accessor :app

  def initialize(app)
    @app = app
  end

  def Generator.generate_all
    self.subclasses.each do |str|
      str.constantize.new(app).generate(:prefix => true)
    end
  end

  def generate
    gen_app
    app.models.values.each do |model|
      gen_routes
      gen_migration(model)
      gen_model(model)
      gen_controller(model)
      gen_view(model)
    end
  end
end
