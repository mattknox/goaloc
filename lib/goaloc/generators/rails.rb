require "erb"
require "fileutils"

class Rails < RubyGenerator
  attr_accessor :app, :opts
  def initialize(app, opts = { })
    @app = app
    @opts = opts
    Goal.instance_eval( "include RailsModel" ) unless Goal.new("foobar").respond_to?(:rails_association_string)
  end

  module RailsModel
    def rails_association_string(assoc_name, assoc_hash)
      option_str = ""
      option_str << ", :through => :#{assoc_hash[:through].p}" if assoc_hash[:through]
      "#{assoc_hash[:type]} :#{assoc_name + option_str}"
    end
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

  def gen_model_str(goal)
    out = ""
    out << "class #{goal.cs} < ActiveRecord::Base\n"
    goal.associations.each do |k, v|
      out <<  "  #{goal.rails_association_string(k,v)}\n"
    end
    goal.validations.each do |v|
      out << "  validates_#{v[:val_type]} :#{v[:field]}\n"
    end
    out <<  "end"
  end
end

#   module RailsModel
#     def rails_ivar_or_array_of_ivars(end_index = -1)
#       "[" + self.resource_tuple[0..end_index].map {|c| c.rails_symname }.join(", ") + "]"
#     end
    
#     def rails_backvar_tuple(end_element = "form")
#       # this is intended to grab the list of elements needed to populate a form_for,
#       # propagated back from the named end_element
#       # so for [:users, [:posts, [:comments, :ratings]]] in the rating form it would be:
#       # form.comment.post.user, form.comment.post, form.comment, form
#       self.resource_tuple[0..-2].map {|c| c.s }.reverse.inject([end_element]) {|acc, x| acc.unshift(acc.first + "." + x )}
#     end
#     def rails_underscore_tuple
#       self.resource_tuple.map {|c| c.s }
#     end
    
#     def rails_object_path(str = "@")
#       self.rails_underscore_tuple.join("_") + '_path(' + (self.rails_ivar_tuple[0..-2]  + ["#{str.to_s + self.s})"]).join(', ')
#     end
    
#     def rails_edit_path(str = nil)
#       if str
#         "edit_" + self.rails_object_path(str)
#       else
#         "edit_" + self.rails_object_path
#       end
#     end
    
#     def rails_new_path
#       "new_" + (self.rails_underscore_tuple[0..-2] + ["#{self.s}"]).join("_") + "_path(" + self.rails_ivar_tuple(-2).join(', ') + ')'
#     end

#     def rails_collection_path 
#       (self.rails_underscore_tuple[0..-2] + [self.p]).join("_") +  "_path(" + self.rails_ivar_tuple(-2).join(', ') + ')'
#     end

#     def nested?
#       self.resource_tuple.length > 1
#     end
    
#     # this returns @foo = Foo.find(params[:param_name]) or @foo = @bar.foos.find(params[:param_name])
#     def rails_finder_string(id_str = nil)
#       id_str ||= "#{self.s}_id"
#       if self.nested?
#         enclosing_resource = self.resource_tuple[-2]
#         "@#{self.s} = @#{enclosing_resource.s}.#{self.p}.find(params[:#{id_str}])"
#       else
#         "@#{self.s} = #{self.cs}.find(params[:#{id_str}])"
#       end
#     end

#     def rails_test_var_string
#       if self.nested?
#         enclosing_resource = self.resource_tuple[-2]
#         "@#{self.s} = @#{enclosing_resource.s}.#{self.p}.find(:first)"
#       else
#         "@#{self.s} = #{self.cs}.find(:first)"
#       end
#     end
    
#     def rails_collection_finder_string
#       if self.nested?
#         enclosing_resource = self.resource_tuple[-2]
#         "@#{self.p} = @#{enclosing_resource.s}.#{self.p}"
#       else
#         "@#{self.p} = #{self.cs}.find(:all)"
#       end
#     end

#     def rails_new_object_string
#       if self.nested?
#         enclosing_resource = self.resource_tuple[-2]
#         "@#{self.s} = @#{enclosing_resource.s}.#{self.p}.new(params[:#{self.s}])"
#       else
#         "@#{self.s} = #{self.cs}.new(params[:#{self.s}])"
#       end
#     end
    
#     # TODO: right now this doesn't handle routes that have an multiply routed resource in the chain somewhere
#     # eg route :blogs, [:users, [:blogs, :posts]]  It's obvious in posts that blogs is the nested bit.  
#     def rails_find_method
#       wrap_method("find_#{self.s}",
#                   self.resource_tuple[0..-2].map { |var| var.rails_finder_string } +
#                   [self.rails_finder_string("id")] + 
#                   self.nested_resources.map { |k,v| v.rails_new_object_string()})
#     end

#     def rails_find_collection_method
#       wrap_method("find_#{self.p}", (self.resource_tuple[0..-2].map { |var| var.rails_finder_string } +
#                                      [self.rails_collection_finder_string, self.rails_new_object_string]))
#     end
    
#     def rails_new_object_method
#       wrap_method("new_#{self.s}", (self.resource_tuple[0..-2].map { |var| var.rails_finder_string } +
#                                     [self.rails_new_object_string]))
#     end

#     def rails_required_nonpath_params
#       self.associations.reject { |k,v| v[:type] != :belongs_to }.keys.reject {|x| self.resource_tuple.map { |y| y.s }.member?(x) }
#     end

#     def rails_required_nonpath_param_string
#       rails_required_nonpath_params.map { |z| ":#{ z.singularize }_id => 1" }.join(", ")
#     end
    
#     def wrap_method(name, arr, indent_string = "  ")
#       indent_string + "def #{name}\n" + arr.map { |s| indent_string + "  " + s }.join("\n") + "\n#{indent_string}end"
#     end

#     def rails_association_string(assoc_name, assoc_hash)
#       option_str = ""
#       option_str << ", :through => :#{assoc_hash[:through].p}" if assoc_hash[:through]
#       "#{assoc_hash[:type]} :#{assoc_name + option_str}"
#     end

#     def rails_field_string(name, type)
#       case type
#       when "text" then "    <%= f.text_area :#{name} %" + ">"
#       when "foreign_key" then "    <%= f.select :#{name}, #{name[0..-4].camelize}.find(:all).map { |x| ['#{name}' + x.id.to_s, x.id]} %>"
#       else "    <%= f.text_field :#{name} %" + ">"
#       end
#     end
#   end
  
#   def generate()
#     app.models.values.map { |m| railsify(m) unless m.respond_to?(:rails_find_method) }
    
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

#   def railsify(model)
#     model.class_eval( "extend RailsModel" )
#     model
#   end

#   def app_name
#     name = app.name.clone
#     name << "_rails" if opts[:prefix]
#     name
#   end

#   def options
#     "-d mysql "
#   end
  
#   def gen_app  # TODO:  this is just heinous.  Get rid of it.  Ideally make it possible to do a suspecders-like thing.
#     if opts[:template]
#       gen_from_suspenders
#     else
#       ` #{ rails_str} `
#     end
#   end

#   def gen_from_suspenders
#     raise :not_yet_implemented
#   end

#   def rails_str
#     "rails #{ options} #{app_name}"
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

#   def gen_migration_string(model)
#     template_str = File.open("#{File.dirname(__FILE__)}/rails/migration.rb.erb").read
#     ERB.new(template_str).result(binding)
#   end
  
#   def gen_migration(model)
#     Dir.mkdir "#{app_name}/db/migrate" unless File.exists? "#{app_name}/db/migrate"
#     f = File.new("#{app_name}/db/migrate/#{ Time.now.strftime("%Y%m%d%H%M%S") }_create_#{model.p}.rb", "w")
#     Kernel.sleep(1)  # FIXME: get rid of this nasty hack.
#                      # TODO: I should make a migration_order accessor, so people can define the order in which migrations happen.  This would also, coincidentally, allow me to get rid of the Kernel.sleep(1) hack.
#     f.write gen_migration_string(model)
#     f.close
#   end
  
#   def gen_model(model)
#     f = File.new("#{app_name}/app/models/#{model.nice_name}.rb", "w") 
#     f.write "class #{model.to_s} < ActiveRecord::Base\n"
#     model.associations.each do |k, v|
#       f.write "  #{model.rails_association_string(k,v)}\n"
#     end
#     model.validations.each do |k, v|
#       f.write "  #{v[:type]} :#{v[:target]}\n"
#     end
#     f.write "end"
#     f.close
#   end

#   def gen_controller_string(model)
#     template_str = File.open("#{File.dirname(__FILE__)}/rails/controller.rb.erb").read
#     ERB.new(template_str).result(binding)
#   end
  
#   def gen_controller(model)              # make this a better controller
#     f = File.new("#{app_name}/app/controllers/#{model.nice_name.pluralize}_controller.rb", "w") 
#     f.write(gen_controller_string(model))
#     f.close
#   end

#   def gen_index_string(model)
#     template_str = File.open("#{File.dirname(__FILE__)}/rails/index.html.erb").read
#     ERB.new(template_str).result(binding)
#   end

#   def gen_form_string(model)
#     template_str = File.open("#{File.dirname(__FILE__)}/rails/_form.html.erb").read
#     ERB.new(template_str).result(binding)
#   end

#   def gen_show_string(model)
#     template_str = File.open("#{File.dirname(__FILE__)}/rails/show.html.erb").read
#     ERB.new(template_str).result(binding)
#   end
  
#   def gen_partial_string(model)
#     template_str = File.open("#{File.dirname(__FILE__)}/rails/_model.html.erb").read
#     ERB.new(template_str).result(binding)
#   end

#   def gen_small_partial_string(model)
#     template_str = File.open("#{File.dirname(__FILE__)}/rails/_model_small.html.erb").read
#     ERB.new(template_str).result(binding)
#   end

#   def gen_view(model)
#     cs = model.to_s                      # singular capitalized
#     cp = model.to_s.pluralize            # singular capitalized
#     s  = model.to_s.underscore           # singular lowercase
#     p  = model.to_s.underscore.pluralize # plural lowercase

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
#     f.write "<%= render :partial => '#{p}/form', :object => @#{s} %>"
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

#   def exemplar_data(data_type)
#     case data_type
#     when "integer" then rand(100)
#     else data_type + rand(100).to_s
#     end
#   end
  
#   def gen_fixture_string(model, n)
#     out = ""
#     (1..n).each do |i|
#       out << "#{model.s}#{i}:\n"
#       out << "  id: #{i}\n"
#       model.fields.each do |k, v|
#         out << "  #{k}: #{exemplar_data(v)}\n"
#       end
#       model.foreign_keys.uniq.each do |key|
#         out << "  #{key}: #{i}\n"
#       end
#       out << "\n"
#     end
#     out
#   end

#   def gen_fixture(model)
#     File.open("#{app_name}/test/fixtures/#{model.p}.yml", "w") do |f|
#       f.write gen_fixture_string(model, 100)
#     end
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
