require "fileutils"

class Generator
  attr_accessor :root_dir  # this is the directory in which the app will be generated
  attr_accessor :app, :opts, :generator
  def initialize(app, opts = { })
    @app = app
    @opts = opts
    @generator = self
  end

#   def Generator.generate_all(opts = { })
#     self.subclasses.each do |str|
#       str.constantize.new(app, opts.merge(:prefix => true)).generate
#     end
#   end

  # this builds an app for the target platform
  def Generator.build(app, target, opts = { })
    if Generator.subclasses.member?(target.to_s)
      target.new(app, opts)
    else
      raise RuntimeError
    end
  end

  def gen_string(name, *args)
    goal = args.first
    template_str = File.open("#{File.dirname(__FILE__)}/#{self.class.to_s.underscore}/#{name}.erb").read
    ERB.new(template_str).result(binding)
  end

  def gen_file(path, name, *args)
    goal = args.first
    FileUtils.mkdir_p path unless File.exists? path
    File.open("#{app_dir}/#{path}", "w") do |f|
      f.write gen_string(name, *args)
    end
  end
end
