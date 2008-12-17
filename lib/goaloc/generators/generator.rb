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
  # TODO: put the 'goaloc string'-the stuff to feed to goaloc needed to regenerate the app.
  # TODO: move a lot of the duplicated stuff from rails/merb into here.
  #   then the various generators just have to provide appropriate templates.
end
