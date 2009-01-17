require "erb"
require "fileutils"

class Rails < RubyGenerator
  attr_accessor :app, :opts, :generator
  def initialize(app, opts = { })
    @app = app
    @opts = opts
    @generator = self
  end

  def association_string(assoc_name, assoc_hash)
    option_str = ""
    option_str << ", :through => :#{assoc_hash[:through].p}" if assoc_hash[:through]
    "#{assoc_hash[:type]} :#{assoc_name + option_str}"
  end
  
  def wrap_method(name, arr, indent_string = "  ")
    indent_string + "def #{name}\n" + arr.map { |s| indent_string + "  " + s }.join("\n") + "\n#{indent_string}end"
  end
  
  # TODO: right now this doesn't handle routes that have an multiply routed resource in the chain somewhere
  # eg route :blogs, [:users, [:blogs, :posts]]  It's obvious in posts that blogs is the nested bit.  
  def find_method(goal)
    wrap_method("find_#{goal.s}",
                goal.resource_tuple[0..-2].map { |var| finder_string(var.to_s.singularize.camelize.constantize) } +
                [finder_string(goal, "id")] + 
                goal.nested_resources.map { |k,v| new_object_string(v)})
  end
  
  # this returns @foo = Foo.find(params[:param_name]) or @foo = @bar.foos.find(params[:param_name])
  def finder_string(goal, id_str = nil)
    id_str ||= "#{goal.s}_id"
    if goal.nested?
      enclosing_resource = @app.fetch_goal(goal.resource_tuple[-2])
      "@#{goal.s} = @#{enclosing_resource.s}.#{goal.p}.find(params[:#{id_str}])"
    else
      "@#{goal.s} = #{goal.cs}.find(params[:#{id_str}])"
    end
  end
  
  def new_object_string(goal)
    if goal.nested?
      enclosing_resource = @app.fetch_goal(goal.resource_tuple[-2])
      "@#{goal.s} = @#{enclosing_resource.s}.#{goal.p}.new(params[:#{goal.s}])"
    else
      "@#{goal.s} = #{goal.cs}.new(params[:#{goal.s}])"
    end
  end
  
  def collection_finder_string(goal)
    if goal.nested?
      enclosing_resource = @app.fetch_goal(goal.resource_tuple[-2])
      "@#{goal.p} = @#{enclosing_resource.s}.#{goal.p}"
    else
      "@#{goal.p} = #{goal.cs}.find(:all)"
    end
  end
  
  def new_object_method(goal)
    wrap_method("new_#{goal.s}", (goal.resource_tuple[0..-2].map { |var| finder_string(@app.fetch_goal(var)) } +
                                  [new_object_string(goal)]))
  end

  def find_collection_method(goal)
    wrap_method("find_#{goal.p}", (goal.resource_tuple[0..-2].map { |var| finder_string(@app.fetch_goal(var)) } +
                                   [collection_finder_string(goal), new_object_string(goal)]))
  end

  def object_path(goal, str = "@")
    goal.underscore_tuple.join("_") + '_path(' + (goal.ivar_tuple[0..-2]  + ["#{str.to_s + goal.s})"]).join(', ')
  end
  
  def edit_path(goal, str = nil)
    if str
      "edit_" + goal.rails_object_path(str)
    else
      "edit_" + goal.rails_object_path
    end
  end
  
  def new_path(goal)
    "new_" + (goal.rails_underscore_tuple[0..-2] + ["#{goal.s}"]).join("_") + "_path(" + goal.rails_ivar_tuple(-2).join(', ') + ')'
  end
  
  def collection_path(goal)
    (goal.underscore_tuple[0..-2] + [goal.p]).join("_") +  "_path(" + goal.ivar_tuple[0..-2].join(', ') + ')'
  end
  
  def generate
  end
  
  def gen_route_string # TODO: add a default route
    "ActionController::Routing::Routes.draw do |map|\n" +
      default_route.to_s + 
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

  def gen_migration_str(goal)
    template_str = File.open("#{File.dirname(__FILE__)}/rails/migration.rb.erb").read
    ERB.new(template_str).result(binding)
  end
  
  def gen_model_str(goal)
    out = ""
    out << "class #{goal.cs} < ActiveRecord::Base\n"
    goal.associations.each do |k, v|
      out <<  "  #{association_string(k,v)}\n"
    end
    goal.validations.each do |v|
      out << "  validates_#{v[:val_type]} :#{v[:field]}\n"
    end
    out <<  "end"
  end

  def gen_controller_str(goal)
    template_str = File.open("#{File.dirname(__FILE__)}/rails/controller.rb.erb").read
    ERB.new(template_str).result(binding)
  end

  # view stuff
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
    "<%= render :partial => '#{goal.p}/form', :object => @#{goal.s} %>"
  end

  def field_string(name, type)
    case type
    when "text" then "    <%= f.text_area :#{name} %" + ">"
    when "foreign_key" then "    <%= f.select :#{name}, #{name[0..-4].camelize}.find(:all).map { |x| ['#{name}' + x.id.to_s, x.id]} %>"
    else "    <%= f.text_field :#{name} %" + ">"
    end
  end
end

#     def rails_ivar_or_array_of_ivars(end_index = -1)
#       "[" + self.resource_tuple[0..end_index].map {|c| c.rails_symname }.join(", ") + "]"
#     end
        
#     def rails_test_var_string
#       if self.nested?
#         enclosing_resource = self.resource_tuple[-2]
#         "@#{self.s} = @#{enclosing_resource.s}.#{self.p}.find(:first)"
#       else
#         "@#{self.s} = #{self.cs}.find(:first)"
#       end
#     end
        
#     def rails_required_nonpath_params
#       self.associations.reject { |k,v| v[:type] != :belongs_to }.keys.reject {|x| self.resource_tuple.map { |y| y.s }.member?(x) }
#     end

#     def rails_required_nonpath_param_string
#       rails_required_nonpath_params.map { |z| ":#{ z.singularize }_id => 1" }.join(", ")
#     end
    
#     def rails_association_string(assoc_name, assoc_hash)
#       option_str = ""
#       option_str << ", :through => :#{assoc_hash[:through].p}" if assoc_hash[:through]
#       "#{assoc_hash[:type]} :#{assoc_name + option_str}"
#     end
  
#   def generate()
#     gen_app()
#     @app.models.values.each do |model|
#       gen_routes
#       gen_migration(model)
#       gen_model(model)
#       gen_controller(model)
#       gen_view(model)
#       gen_tests(model)
#       gen_misc
#     end
#   end

#   def gen_routes
#     arr = app.routes
#     insert_string = arr.map { |a| gen_route(a)}.join("\n") + "\n"
#     defroute = gen_default_route
    
#     File.open("#{app_name}/config/routes.rb", "w") do |f|
#       f.write "ActionController::Routing::Routes.draw do |map|\n"
#       f.write insert_string
#       f.write defroute.to_s
#       f.write "end"
#     end
#   end

#   def gen_migration(model)
#     Dir.mkdir "#{app_name}/db/migrate" unless File.exists? "#{app_name}/db/migrate"
#     f = File.new("#{app_name}/db/migrate/#{ Time.now.strftime("%Y%m%d%H%M%S") }_create_#{model.p}.rb", "w")
#     Kernel.sleep(1)  # FIXME: get rid of this nasty hack.
#                      # TODO: I should make a migration_order accessor, so people can define the order in which migrations happen.  This would also, coincidentally, allow me to get rid of the Kernel.sleep(1) hack.
#     f.write gen_migration_string(model)
#     f.close
#   end
  
#   def gen_controller(model)              # make this a better controller
#     f = File.new("#{app_name}/app/controllers/#{model.nice_name.pluralize}_controller.rb", "w") 
#     f.write(gen_controller_string(model))
#     f.close
#   end
  
#   def gen_view(model)

#     view_dir = "#{app_name}/app/views/#{p}/"
#     Dir.mkdir view_dir rescue nil
#     File.open("#{view_dir}index.html.erb", "w") do |f|
#       f.write self.gen_index_string(model)
#     end
    
#     File.open("#{view_dir}show.html.erb", "w") do |f|
#       f.write self.gen_show_string(model)
#     end
    
#     File.open("#{view_dir}_#{model.s}.html.erb", "w") do |f|
#       f.write self.gen_partial_string(model)
#     end
    
#     File.open("#{view_dir}_#{model.s}_small.html.erb", "w") do |f|
#       f.write self.gen_small_partial_string(model)
#     end
    
#     f = File.new("#{view_dir}new.html.erb", "w")
#     f.write "<%= render :partial => '#{p}/form', :object => @#{s} %>"
#     f.close
#     f = File.new("#{view_dir}edit.html.erb", "w") 
#     f.write 
#     f.close
#     File.open("#{view_dir}_form.html.erb", "w") do |f|
#       f.write self.gen_form_string(model)
#     end
#     "<% form_for(@#{s}) do |f| %>\n  <%= f.error_messages %>"
#     model.fields.each do |k, v|
#        "
#   <div>
#     <%= f.label :#{k} %><br />
#     <%= f.text_field :#{k} %>
#   </div>\n"
#     end
#      "
#   <div>
#     <%= f.submit 'Update' %>
#   </div>
# <% end %>"
    
#   end

#   def gen_default_route  # this is nasty.  Somehow needs to isolate the route writing from the file clobbering.
#     if 1 == app.routes.length
#       unwrappedroute = app.routes.first.to_a
#       File.delete("#{app_name}/public/index.html") rescue nil
#       "  map.root :controller => '#{unwrappedroute.first}'"
#     else
#       File.open("#{app_name}/public/index.html", "w") do |f|
#         f.write "this will be the index page of the app.  But it isn't yet."
#         app.routes.map { |x| sym = (x.is_a?(Array) ? x.first : x) ; f.write "<div><a href=/#{sym}>#{sym}</a><br/></div>" }
#       end
#       ""
#     end
#   end
  
#   def gen_unit_test_string(model)
#     template_str = File.open("#{File.dirname(__FILE__)}/rails/model_test.rb.erb").read
#     ERB.new(template_str).result(binding)
#   end
  
#   def gen_unit_test(model)
#     Dir.mkdir "#{app_name}/test/unit" unless File.exists? "#{app_name}/test/unit"
#     f = File.new("#{app_name}/test/unit/#{ model.s }_test.rb", "w")
#     f.write gen_unit_test_string(model)
#     f.close
#   end

#   def gen_controller_test_string(model)
#     template_str = File.open("#{File.dirname(__FILE__)}/rails/controller_test.rb.erb").read
#     ERB.new(template_str).result(binding)
#   end
  
#   def gen_controller_test(model)
#     Dir.mkdir "#{app_name}/test/functional" unless File.exists? "#{app_name}/test/functional"
#     f = File.new("#{app_name}/test/functional/#{ model.p }_controller_test.rb", "w")
#     f.write gen_controller_test_string(model)
#     f.close
#   end
  
#   def gen_tests(model)
#     # TODO: get shoulda into place.
#     gen_unit_test(model)
#     gen_controller_test(model)
#     gen_fixture(model)
#   end

#   def gen_misc # here we put in the layout, the goaloc log, and libraries (blueprint CSS, jquery)
#     File.open("#{app_name}/app/views/layouts/application.html.erb", "w") do |f|
#       f.write File.open("#{File.dirname(__FILE__)}/rails/application.html.erb").read
#     end
#     File.open("#{app_name}/doc/goaloc_spec", "w") do |f|
#       f.write app.goaloc_log.join("\n")
#     end
#     FileUtils.cp_r("#{File.dirname(__FILE__)}/resources/bluetrip", "#{app_name}/public/stylesheets")
#     FileUtils.cp_r("#{File.dirname(__FILE__)}/resources/jquery-1.2.6.min.js", "#{app_name}/public/javascripts")
#     FileUtils.cp_r("#{File.dirname(__FILE__)}/resources/shoulda", "#{app_name}/vendor/plugins/")
#   end

#   def gen_default_route  # this is nasty.  Somehow needs to isolate the route writing from the file clobbering.
#     if 1 == app.routes.length
#       unwrappedroute = app.routes.first.to_a
#       File.delete("#{app_name}/public/index.html") rescue nil
#       "  map.root :controller => '#{unwrappedroute.first}'"
#     else
#       File.open("#{app_name}/public/index.html", "w") do |f|
#         f.write "this will be the index page of the app.  But it isn't yet."
#         app.routes.map { |x| sym = (x.is_a?(Array) ? x.first : x) ; f.write "<div><a href=/#{sym}>#{sym}</a><br/></div>" }
#       end
#       ""
#     end
#   end
