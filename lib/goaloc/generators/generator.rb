class Generator
  attr_accessor :app, :opts

  def initialize(app, opts = { })
    @app = app
    @opts = opts
  end

  def Generator.generate_all(opts = { })
    self.subclasses.each do |str|
      str.constantize.new(app, opts.merge(:prefix => true)).generate
    end
  end
  # TODO: move a lot of the duplicated stuff from rails/merb into here.
  #   then the various generators just have to provide appropriate templates.

  
end
