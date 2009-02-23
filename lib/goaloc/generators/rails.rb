require "erb"
require "fileutils"

class Rails < RubyGenerator
  # wraps an array of lines in a method call, with a given name, using a given indentation.
  def wrap_method(name, arr, indent_string = "  ")
    indent_string + "def #{name}\n" + arr.map { |s| indent_string + "  " + s }.join("\n") + "\n#{indent_string}end"
  end
  
  # TODO: right now this doesn't handle routes that have an multiply routed resource in the chain somewhere
  # eg route :blogs, [:users, [:blogs, :posts]]  It's obvious in posts that blogs is the nested bit.
  # to fix this, I'll need to pass the context to find_object_method.
  def find_object_method(goal)
    wrap_method("find_#{goal.s}", ["setup_enclosing_resources", finder_string(goal, "id")] + goal.nested_resources.map { |k,v| new_object_string(v)})
  end
  
  def new_object_method(goal)
    wrap_method("new_#{goal.s}", ["setup_enclosing_resources", new_object_string(goal)])
  end

  def find_collection_method(goal)
    wrap_method("find_#{goal.p}", ["setup_enclosing_resources", collection_finder_string(goal)])
  end

  def setup_enclosing_resources_method(goal)  #TODO:  make this not be there, and not be called, if it's not needed.  
    wrap_method("setup_enclosing_resources", goal.enclosing_goals.map { |goal| finder_string(goal) })
  end
  
  # this returns @foo = Foo.find(params[:param_name]) or @foo = @bar.foos.find(params[:param_name])
  def finder_string(goal, id_str = "#{goal.s}_id")
    ivar_assignment_string(goal, ".find(params[:#{id_str}])", ".find(params[:#{id_str}])")
  end
  
  # returns the string necessary to assign a newly created instance of goal to an instance variable.  
  def new_object_string(goal)
    ivar_assignment_string(goal, ".new(params[:#{goal.s}])", ".new(params[:#{goal.s}])")
  end

  #returns a string assigning a collection of goal elements to an instance variable.
  def collection_finder_string(goal)
    ivar_assignment_string(goal, "", ".find(:all)", "p")
  end
  
  def test_var_string(sym)
    ivar_assignment_string(app.fetch_or_create_goal(sym), ".find(:first)", ".find(:first)")
  end

  def ivar_assignment_string(goal, nested_str, unnested_str, string_meth_for_ivar = "s")
    if goal.nested?
      "@#{goal.send(string_meth_for_ivar)} = @#{goal.enclosing_goal.s}.#{goal.p}" + nested_str
    else
      "@#{goal.send(string_meth_for_ivar)} = #{goal.cs}" + unnested_str
    end
  end

  def required_nonpath_param_string(goal)
    goal.required_nonpath_params.map { |z| ":#{ z.singularize }_id => 1" }.join(", ")
  end

  def object_path(goal, str = "@")
    goal.underscore_tuple.join("_") + '_path(' + (goal.ivar_tuple[0..-2]  + ["#{str.to_s + goal.s})"]).join(', ')
  end

  def collection_path(goal)
    (goal.underscore_tuple[0..-2] + [goal.p]).join("_") +  "_path(" + goal.ivar_tuple[0..-2].join(', ') + ')'
  end

  # the core method that generates the whole app.  
  def generate
    gen_app
    handle_public_index
    gen_file("config/routes.rb", "routes")
    @app.goals.values.each_with_index { |goal, i| gen_goal(goal, i) }
    gen_misc
    self
  end

  # this does all of the generation for a given goal
  def gen_goal(goal, index = 0)
    gen_file("db/migrate/#{ Time.now.strftime("%Y%m%d%H%M%S").to_i + index }_create_#{goal.p}.rb", "migration", goal)

    # TODO: make a thing that returns the innards of the class, preferably organized into
    # validations, associations, requires/acts_as clauses, class, instance, and private methods.
    # also add something that tells a goal not to generate any combo of model/view/controller.
    gen_file("/app/models/#{goal.s}.rb", "model", goal)
    gen_file("/app/controllers/#{goal.p}_controller.rb", "controller", goal)
    gen_view(goal)
    gen_tests(goal)
  end

  # gen_app will generate a rails skeleton, using a shell-out to the rails command
  # if the directory already exists, it will do nothing, which means that it will silently
  # overwrite files in an existing directory.  So far, that's the best thing I can think of to do.
  def gen_app
    unless File.exists?(app_dir) 
      original_dir = FileUtils.pwd
      Dir.mkdir(root_dir) unless (!root_dir or File.exists?(root_dir))
      FileUtils.cd(root_dir) if root_dir
      `#{rails_str}`
      FileUtils.cd(original_dir)
      true
    end
  end
  
  def handle_public_index
    if !default_route.blank?
      File.delete("#{app_dir}/public/index.html") rescue nil
    else
      File.open("#{app_dir}/public/index.html", "w") do |f|
        f.write "this will be the index page of the app.  But it isn't yet."
        app.routes.map { |x| sym = (x.is_a?(Array) ? x.first : x) ; f.write "<div><a href=/#{sym}>#{sym}</a><br/></div>" }
      end
    end    
  end
  
  def gen_view(goal)
    view_dir = "app/views/#{goal.p}/"

    gen_file("#{view_dir}index.html.erb", "index", goal)
    gen_file("#{view_dir}show.html.erb", "show", goal)
    gen_file("#{view_dir}edit.html.erb", "edit", goal)
    gen_file("#{view_dir}new.html.erb", "edit", goal)
    gen_file("#{view_dir}_#{goal.s}.html.erb", "_model", goal)
    gen_file("#{view_dir}_#{goal.s}_small.html.erb", "_model_small", goal)
    gen_file("#{view_dir}_form.html.erb", "_form", goal)
  end
  
  def gen_tests(goal)
    gen_file("/test/unit/#{goal.s}_test.rb", "unit_test", goal)
    gen_file("/test/functional/#{goal.p}_controller_test.rb", "controller_test", goal)
    gen_fixture(goal)
  end

  def exemplar_data(data_type)
    case data_type
    when "integer" then rand(100)
    else data_type + rand(100).to_s
    end
  end
  
  def gen_fixture_string(goal, n)
    out = ""
    (1..n).each do |i|
      out << "#{goal.s}#{i}:\n"
      out << " id: #{i}\n"
      goal.fields.each do |k, v|
        out << " #{k}: #{exemplar_data(v)}\n"
      end
      goal.foreign_keys.each do |key, value|
        out << " #{key}: #{i}\n"
      end
      out << "\n"
    end
    out
  end
 
  def gen_fixture(goal)
    File.open("#{app_dir}/test/fixtures/#{goal.p}.yml", "w") do |f|
      f.write gen_fixture_string(goal, 100)
    end
  end

  def gen_misc # here we put in the layout, the goaloc log, and libraries (blueprint CSS, jquery)
    File.open("#{app_dir}/app/views/layouts/application.html.erb", "w") do |f|
      f.write ERB.new(File.open("#{File.dirname(__FILE__)}/rails/application.erb").read).result(binding)
    end
    File.open("#{app_dir}/doc/goaloc_spec", "w") do |f|
      f.write app.goaloc_log.join("\n")
    end
    FileUtils.cp_r("#{File.dirname(__FILE__)}/resources/bluetrip", "#{app_dir}/public/stylesheets")
    FileUtils.cp_r("#{File.dirname(__FILE__)}/resources/jquery-1.2.6.min.js", "#{app_dir}/public/javascripts")
    FileUtils.cp("#{File.dirname(__FILE__)}/resources/test_helper.rb", "#{app_dir}/test/")
  end

  def rails_str
    "rails #{ options} #{app_name}"
  end

  # goaloc supports all of the various options that one can set when generating
  # a rails app, by either the long or short name, with or without dashes
  def options
    db = (opts["-d"] or opts["d"] or opts["--database"] or opts["database"] or "mysql")
    rubypath = (opts["-r"] or opts["r"] or opts["--ruby"] or opts["ruby"] )
    rubypath = "--ruby=#{rubypath}" if rubypath
    nullary_opts = %w{ -f --freeze --force -s --skip -q --quiet -c --svn -g --git }.reject { |x| !opts.has_key?(x) and !opts.has_key?(x.gsub(/-/, ""))}
    "-d #{db} #{rubypath}" + nullary_opts.join(" ")
  end
  
  def gen_route(x, var = "map", pad = "  ") # turn a sym or array into a potentially nested route
    if x.is_a? Symbol
      pad + "#{var}.resources :#{x.to_s}"
    elsif x.is_a? Array
      pad + "#{var}.resources :#{x.first.to_s} do |#{x.first.to_s.singularize}|\n" +
        x[1..-1].map { |y| gen_route(y, x.first.to_s.singularize, pad + "  ")}.join("\n") + "\n" +
        pad + "end"
    end
  end
  
  def default_route
    "  map.root :controller => '#{app.routes.first.to_a.first}'" if app.routes.length == 1
  end
end
