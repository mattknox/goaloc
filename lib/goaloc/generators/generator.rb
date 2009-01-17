class Generator
#   def Generator.generate_all(opts = { })
#     self.subclasses.each do |str|
#       str.constantize.new(app, opts.merge(:prefix => true)).generate
#     end
#   end

  def Generator.build(app, target, opts = { })
    if Generator.subclasses.member?(target.to_s)
      target.new(app, opts)
    else
      raise RuntimeError
    end
  end

  def app_name
    name = self.app.name.clone
    name << "_#{self.class.to_s.underscore}"
  end
end
