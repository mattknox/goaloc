require "erb"
require "fileutils"

# TODO: seperate out the actionview parts, in prep for Rails3
class Rails < RubyGenerator
  # NAMES_PATHS is a hash of template filename => destination filename pairs
  # the destination filenmaes need to be lambdas so they can insert the goal
  # name into destination filename as appropriate.
  DESTINATION_PATHS = { "model" => lambda { |goal| "#{app_name}/app/models/#{goal.s}.rb"}  }
  
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
  
  # TODO: extract the commonality out of this pair of methods.
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

  # returns a list of all the params that are required for a goal but not inferrable from the path in which it is encountered.  
  def required_nonpath_params(goal)
    goal.associations.reject { |k,v| v[:type] != :belongs_to }.keys.reject {|x| goal.resource_tuple.map { |y| y.to_s.singularize }.member?(x) }
  end
  
  def required_nonpath_param_string(goal)
    required_nonpath_params(goal).map { |z| ":#{ z.singularize }_id => 1" }.join(", ")
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
    gen_routes
    @app.goals.values.each_with_index { |goal, i| gen_goal(goal, i) }
    gen_misc
    self
  end

  # this does all of the generation for a given goal
  def gen_goal(goal, index = 0)
    gen_migration(goal, index)
    gen_model(goal)
    gen_controller(goal)
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
  
  def need_public_index?
    default_route.blank?
  end
  
  def handle_public_index
    if !need_public_index?
      File.delete("#{app_dir}/public/index.html") rescue nil
    else
      File.open("#{app_dir}/public/index.html", "w") do |f|
        f.write "this will be the index page of the app.  But it isn't yet."
        app.routes.map { |x| sym = (x.is_a?(Array) ? x.first : x) ; f.write "<div><a href=/#{sym}>#{sym}</a><br/></div>" }
      end
    end    
  end
  
  def gen_routes
    handle_public_index
    File.open("#{app_dir}/config/routes.rb", "w") do |f|
      f.write gen_routes_string
    end
  end
  
  def gen_migration(goal, i)
    Dir.mkdir "#{app_dir}/db/migrate" unless File.exists? "#{app_dir}/db/migrate"
    f = File.new("#{app_dir}/db/migrate/#{ Time.now.strftime("%Y%m%d%H%M%S").to_i + i }_create_#{goal.p}.rb", "w")
    f.write gen_migration_str(goal)
    f.close
  end
  
  def gen_controller(goal)              # make this a better controller
    f = File.new("#{app_dir}/app/controllers/#{goal.p}_controller.rb", "w") 
    f.write(gen_controller_str(goal))
    f.close
  end
  
  def gen_view(goal)
    view_dir = "#{app_dir}/app/views/#{goal.p}/"
    Dir.mkdir view_dir unless File.exists?(view_dir)
    File.open("#{view_dir}index.html.erb", "w") do |f|
      f.write self.gen_index_str(goal)
    end
    
    File.open("#{view_dir}show.html.erb", "w") do |f|
      f.write self.gen_show_str(goal)
    end
    
    File.open("#{view_dir}_#{goal.s}.html.erb", "w") do |f|
      f.write self.gen_partial_str(goal)
    end
    
    File.open("#{view_dir}_#{goal.s}_small.html.erb", "w") do |f|
      f.write self.gen_partial_small_str(goal)
    end
    
    f = File.new("#{view_dir}new.html.erb", "w")
    f.write "<%= render :partial => '#{goal.p}/form', :object => @#{goal.s} %>"
    f.close
    f = File.new("#{view_dir}edit.html.erb", "w") 
    f.write "<%= render :partial => '#{goal.p}/form', :object => @#{goal.s} %>"
    f.close
    File.open("#{view_dir}_form.html.erb", "w") do |f|
      f.write self.gen_form_str(goal)
    end
  end
  
  def gen_tests(goal)
    # TODO: get shoulda into place.
    gen_unit_test(goal)
    gen_controller_test(goal)
    gen_fixture(goal)
  end

  def gen_unit_test(goal)
    Dir.mkdir "#{app_dir}/test/unit" unless File.exists? "#{app_dir}/test/unit"
    f = File.new("#{app_dir}/test/unit/#{ goal.s }_test.rb", "w")
    f.write gen_unit_test_string(goal)
    f.close
  end

  def gen_controller_test(goal)
    Dir.mkdir "#{app_dir}/test/functional" unless File.exists? "#{app_dir}/test/functional"
    f = File.new("#{app_dir}/test/functional/#{ goal.p }_controller_test.rb", "w")
    f.write gen_controller_test_string(goal)
    f.close
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
      f.write ERB.new(File.open("#{File.dirname(__FILE__)}/rails/application.html.erb").read).result(binding)
    end
    File.open("#{app_dir}/doc/goaloc_spec", "w") do |f|
      f.write app.goaloc_log.join("\n")
    end
    FileUtils.cp_r("#{File.dirname(__FILE__)}/resources/bluetrip", "#{app_dir}/public/stylesheets")
    FileUtils.cp_r("#{File.dirname(__FILE__)}/resources/jquery-1.2.6.min.js", "#{app_dir}/public/javascripts")
    FileUtils.cp("#{File.dirname(__FILE__)}/resources/test_helper.rb", "#{app_dir}/test/")
  end

  def app_dir
    [root_dir, app_name].compact.join("/")
  end

  def app_name
    "#{app.name}" + (opts[:base_dir_suffix] ? "_rails" : "")
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
    
  def gen_routes_string
    "ActionController::Routing::Routes.draw do |map|\n" +
      default_route.to_s + "\n" +
      app.routes.map { |x| gen_route(x)}.join("\n") + "\n" + 
      "end"
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
    if app.routes.length == 1
      "  map.root :controller => '#{app.routes.first.to_a.first}'"
    end
  end

  # TODO: make a thing that returns the innards of the class, preferably organized into
  # validations, associations, requires/acts_as clauses, class, instance, and private methods.
  # also add something that tells a goal not to generate any combo of model/view/controller.
  def gen_model_str(goal)
    out = ""
    out << "class #{goal.cs} < ActiveRecord::Base\n"   # TODO:  make this restrict access to attributes that shouldn't be accessible
    goal.associations.each do |k, v|
      out <<  "  #{ArModel.association_string(k,v)}\n"
    end
    goal.validations.each do |v|
      out << "  validates_#{v[:val_type]} :#{v[:field]}\n"
    end
    out <<  "end"
  end

  # view stuff
  # TODO:  get some method_missing action going on here, to make it so that I don't have to
  # have all these boilerplate methods.  Probably it's enough to have a hash of hashes,
  # keyed on things like "layout", with a name of a file to read and the name of a file to
  # render to.
  def gen_layout_str
    template_str = File.open("#{File.dirname(__FILE__)}/rails/application.html.erb").read
    ERB.new(template_str).result(binding)
  end
  
  def gen_index_str(goal)
    template_str = File.open("#{File.dirname(__FILE__)}/rails/index.html.erb").read
    ERB.new(template_str).result(binding)
  end
  
  def gen_show_str(goal)
    template_str = File.open("#{File.dirname(__FILE__)}/rails/show.html.erb").read
    ERB.new(template_str).result(binding)
  end

  def gen_partial_str(goal)
    template_str = File.open("#{File.dirname(__FILE__)}/rails/_model.html.erb").read
    ERB.new(template_str).result(binding)
  end

  def gen_partial_small_str(goal)
    template_str = File.open("#{File.dirname(__FILE__)}/rails/_model_small.html.erb").read
    ERB.new(template_str).result(binding)
  end

  def gen_form_str(goal)
    template_str = File.open("#{File.dirname(__FILE__)}/rails/_form.html.erb").read
    ERB.new(template_str).result(binding)
  end

  def gen_edit_str(goal)
    "<%= render :partial => '#{goal.p}/form', :object => @#{goal.s} %>"
  end

  def gen_new_str(goal)
    gen_edit_str(goal)
  end

  def field_string(name, type)
    case type
    when "text" then "    <%= f.text_area :#{name} %" + ">"
    when "foreign_key" then "    <%= f.select :#{name}, #{name[0..-4].camelize}.find(:all).map { |x| ['#{name}' + x.id.to_s, x.id]} %>"
    else "    <%= f.text_field :#{name} %" + ">"
    end
  end
end
