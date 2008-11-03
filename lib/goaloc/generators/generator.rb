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
end
