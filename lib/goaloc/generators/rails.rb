require "erb"

class Rails < Generator
  def generate
    gen_app
    app.models.values.each do |model|
      rails_model = railsify(model)
      gen_routes
      gen_migration(rails_model)
      gen_model(rails_model)
      gen_controller(rails_model)
      gen_view(rails_model)
    end
  end

  def railsify(model)
    #TODO: put methods for 
    Object.class_eval "
class Rails#{model} < #{model}
  class << self
    def path
      
    end
  end
end
"
  "Rails#{model}".constantize
  end

#fix this bug!
# NoMethodError: private method `p' called for nil:NilClass  
# 	from ./goaloc/generators/rails.rb:52:in `gen_migration'
# 	from ./goaloc/generators/rails.rb:9:in `generate'
# 	from ./goaloc/generators/rails.rb:6:in `each'
# 	from ./goaloc/generators/rails.rb:6:in `generate'
# 	from ./goaloc/app.rb:16:in `generate'
# 	from ./goaloc.rb:17:in `generate'
# 	from (irb):26

  
  def app_name(opts = { })
    name = app.name
    name << "_rails" if opts[:prefix]
    name
  end

  def gen_app(opts = { })
    `rails -d mysql #{app_name(opts)}`
  end
  
  def gen_routes  # FIXME:  this is pretty bad, but works
    arr = app.routes
    insert_string = arr.map { |a| gen_route(a)}.join("\n") + "\n"
    File.open("#{app_name}/config/routes.rb", "w") do |f|
      f.write "ActionController::Routing::Routes.draw do |map|\n"
      f.write insert_string
      f.write "end"
    end
  end

  def gen_migration_string(model)
    template_str = File.open("./goaloc/generators/rails/migration.rb.erb").read
    ERB.new(template_str).result(binding)
  end
  
  def gen_migration(model)
    Dir.mkdir "#{app_name}/db/migrate" unless File.exists? "#{app_name}/db/migrate"
    f = File.new("#{app_name}/db/migrate/#{ Time.now.strftime("%Y%m%d%H%M%S") }_create_#{model.p}.rb", "w")
    Kernel.sleep(1)  # FIXME: get rid of this nasty hack.
    f.write gen_migration_string(model)
    f.close
  end
  
  def gen_model(model)
    f = File.new("#{app_name}/app/models/#{model.nice_name}.rb", "w") 
    f.write "class #{model.to_s} < ActiveRecord::Base\n"
    model.associations.each do |k, v|
      f.write "  #{v[:type]} :#{k}\n"
    end
    f.write "end"
    f.close
  end

  def gen_controller_string(model)
    template_str = File.open("./goaloc/generators/rails/controller.rb.erb").read
    ERB.new(template_str).result(binding)
  end
  
  def gen_controller(model)              # make this a better controller
    f = File.new("#{app_name}/app/controllers/#{model.nice_name.pluralize}_controller.rb", "w") 
    f.write(gen_controller_string(model))
    f.close
  end
  
  def gen_view(model)
    cs = model.to_s                      # singular capitalized
    cp = model.to_s.pluralize            # singular capitalized
    s  = model.to_s.underscore           # singular lowercase
    p  = model.to_s.underscore.pluralize # plural lowercase

    view_dir = "#{app_name}/app/views/#{p}/"
    Dir.mkdir view_dir
    f = File.new("#{view_dir}index.html.erb", "w")
    f.write "<h1>Listing #{p}</h1>

<table>
  <tr>" + model.fields.map { |k, v| "<th>#{k.capitalize}</th>"}.join("\n") + 
"  </tr>

<% for #{s} in @#{p} %>
  <tr>" + model.fields.map { |k, v| "<td><%=h #{s}.#{k} %></td>"}.join("\n") + 
"    <td><%= link_to 'Show', #{s} %></td>
    <td><%= link_to 'Edit', edit_#{s}_path(#{s}) %></td>
    <td><%= link_to 'Destroy', #{s}, :confirm => 'Are you sure?', :method => :delete %></td>
  </tr>
<% end %>
</table>

<br />

<%= link_to 'New #{s}', new_#{s}_path %>"
    f.close
    f = File.new("#{view_dir}show.html.erb", "w") 
    model.fields.each do |k, v|
      f.write "
  <p>
    <b>#{k}:</b>
    <%=h @#{s}.#{k} %>
  </p>\n"
    end
    f.write "<%= link_to 'Edit', edit_#{s}_path(@#{s}) %> |\n <%= link_to 'Back', #{p}_path %>"
    f.close
    f = File.new("#{view_dir}new.html.erb", "w")
    f.write "<%= render :partial => '#{p}/form', :object => @#{s} %>"
    f.close
    f = File.new("#{view_dir}edit.html.erb", "w") 
    f.write "<%= render :partial => '#{p}/form', :object => @#{s} %>"
    f.close
    f = File.new("#{view_dir}_form.html.erb", "w") #TODO: need to allow for using form-builders.
    f.write "<% form_for(@#{s}) do |f| %>\n  <%= f.error_messages %>"
    model.fields.each do |k, v|
      f.write "
  <p>
    <%= f.label :#{k} %><br />
    <%= f.text_field :#{k} %>
  </p>\n"
    end
    f.write "
  <p>
    <%= f.submit 'Update' %>
  </p>
<% end %>"
    f.close
  end

  def gen_route(x, var = "map", pad = "  ")
    if x.is_a? Symbol
      pad + "#{var}.resources :#{x.to_s}"
    elsif x.is_a? Array
      pad + "#{var}.resources :#{x.first.to_s} do |#{x.first.to_s.singularize}|\n" +
        x[1..-1].map { |y| gen_route(y, x.first.to_s.singularize, pad + "  ")}.join("\n") + "\n" +
      pad + "end"
    end
  end
end
