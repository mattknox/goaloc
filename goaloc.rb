require "rubygems"
require "activesupport"

class App
  attr_accessor :name, :models, :routes, :options, :debug

  def initialize(name, options = { })
    self.name = name
    self.options = options
    self.models = { } # why do I make this a hash, anyway?
    self.routes = []
  end

  def generable?
    !self.name.blank?
  end

  def generate
    if generable?
      Rails.new(self).gen_app
    else
      "I can't do it!  I don't have the power!"
    end
  end

  def destroy
    Rails.new.destroy(self)
  end
  
  def route_usage # FIXME: make this only read once.
    f = File.open("doc/route_usage")
    s = f.read
    f.close
    s
  end

  def route_args(*args)  # really want to name this route.  should I rename it?
    if valid_routeset?(args)
      self.routes += args
      args.each do |a|
        build_model(a, nil)
      end
    else
      puts route_usage
    end
  end
  
  def valid_routeset?(args) # TODO: make this less permissive.
    args.is_a? Array and !args.empty?
  end

  def build_model(arg, route)
    if arg.is_a? Symbol
      register_model!(arg, route)
    elsif arg.is_a? Array
      sym = arg.first
      model = (register_model!(sym, route))
      arg[1..-1].each do |a|
        model.has_many(m = build_model(a, (route.to_a << model)))
        models[m.sym_name].belongs_to(model)
      end
      model
    elsif arg.is_a? Hash
      sym = arg[:model]
      register_model!(sym, route)
    end
  end
  
  def register_model!(arg, route)
    self.models[arg] ||= Model.build_and_route(arg, route)
  end
end

class Model # should I perhaps subclass Model, rather than making an instance?
  def Model.build_and_route(name, route)
    x = Model.make_model_class(name)
#    x.routes << (route.to_a << x)
    x
  end
  
  def Model.make_model_class(name)
    # routes is the set of urls by which you can get to an instance of a class
    Object.class_eval "
    class #{ name.to_s.singularize.camelize} < Model
      cattr_accessor :associations, :fields, :options, :routes, :foreign_keys
      self.associations = { }
      self.fields = { }
      self.foreign_keys = []
      self.options = { }
      self.routes = [] # of the form [:classname, [:otherclass, :classname], ...]

    end"
    name.to_s.singularize.camelize.constantize
  end
  
  class << self
    def nice_name
      self.to_s.underscore
    end

    def sym_name
      self.nice_name.pluralize.to_sym
    end
    
    def default_assoc_name(meth)
      :has_many == meth ? nice_name.pluralize : nice_name
    end
    
    def belongs_to(m, o = { }) associate(:belongs_to, m, o) end
    def has_many(m, o = { })   associate(:has_many, m, o)   end
    def has_one(m, o = { })    associate(:has_one, m, o)    end

    def associate(meth, model, options = { })
      assoc_name = options[:assoc_name] || model.default_assoc_name(meth)
      self.foreign_keys << ( assoc_name.to_s + "_id" ) if meth == :belongs_to  #FIXME: might be something other than assoc_name_id
      self.associations[assoc_name] = { :model => model, :name => assoc_name, :type => meth}.merge(options)
    end

    def add_attrs(*args)
      if args.is_a? Array and args.length == 1
        args.first.split.each do |s|
          name, field_type = s.split(":")
          add_field(name, field_type)
        end
      else # TODO: add handling for hashes or arrays
        raise "bad argument type in add_attrs"
      end 
    end

    def add_field(name, field_type)
      fields[name] = field_type
    end
  end
end

class Generator
  attr_accessor :app

  def initialize(app)
    @app = app
  end

  def Generator.generate_all
    self.subclasses.each do |str|
      str.constantize.new(app).gen_app(:prefix => true)
    end
  end
end

class Rails < Generator
  # TODO:  make fields get into _form.
  # TODO:  make views happen at all.
  def app_name(opts = { })
    name = app.name
    name << "_rails" if opts[:prefix]
    name
  end

  def gen_app(opts = { })
    `rails -d mysql #{app_name(opts)}`
    app.models.values.each do |model|
      gen_routes
      gen_migration(model)
      gen_model(model)
      gen_controller(model)
      gen_view(model)
    end
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
  
  def gen_migration(model)
    cs = model.to_s                      # singular capitalized
    cp = model.to_s.pluralize            # singular capitalized
    s  = model.to_s.underscore           # singular lowercase
    p  = model.to_s.underscore.pluralize # plural lowercase

    Dir.mkdir "#{app_name}/db/migrate" unless File.exists? "#{app_name}/db/migrate"
    f = File.new("#{app_name}/db/migrate/#{ Time.now.strftime("%Y%m%d%H%M%S") }_create_#{p}.rb", "w")
    Kernel.sleep(1)  # FIXME: get rid of this nasty hack.
    f.write """
class Create#{cp} < ActiveRecord::Migration
  def self.up
    create_table :#{p} do |t|
#{ model.fields.map do |k, v| "      t." + v + " :" + k + "\n"; end }
#{ model.foreign_keys.map do |k| "      t.references :" + k + "\n"; end }
    
      t.timestamps
  end
end

  def self.down
    drop_table :#{p}
  end
end
"""
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
  
  def gen_controller(model)              # make this a better controller
    cs = model.to_s                      # singular capitalized
    cp = model.to_s.pluralize            # singular capitalized
    s  = model.to_s.underscore           # singular lowercase
    p  = model.to_s.underscore.pluralize # plural lowercase
    f = File.new("#{app_name}/app/controllers/#{model.nice_name.pluralize}_controller.rb", "w") 
    f.write(<<TEMPLATE)
class #{cp}Controller < ApplicationController
  # GET /#{p}
  # GET /#{p}.xml
  def index
    @#{p} = #{cs}.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @#{p} }
    end
  end

  # GET /#{p}/1
  # GET /#{p}/1.xml
  def show
    @#{s} = #{cs}.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @#{s} }
    end
  end

  # GET /#{p}/new
  # GET /#{p}/new.xml
  def new
    @#{s} = #{cs}.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @#{s} }
    end
  end

  # GET /#{p}/1/edit
  def edit
    @#{s} = #{cs}.find(params[:id])
  end

  # POST /#{p}
  # POST /#{p}.xml
  def create
    @#{s} = #{cs}.new(params[:#{s}])

    respond_to do |format|
      if @#{s}.save
        flash[:notice] = '#{cs} was successfully created.'
        format.html { redirect_to(@#{s}) }
        format.xml  { render :xml => @#{s}, :status => :created, :location => @#{s} }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @#{s}.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /#{p}/1
  # PUT /#{p}/1.xml
  def update
    @#{s} = #{cs}.find(params[:id])

    respond_to do |format|
      if @#{s}.update_attributes(params[:#{s}])
        flash[:notice] = '#{cs} was successfully updated.'
        format.html { redirect_to(@#{s}) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @#{s}.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /#{p}/1
  # DELETE /#{p}/1.xml
  def destroy
    @#{s} = #{cs}.find(params[:id])
    @#{s}.destroy

    respond_to do |format|
      format.html { redirect_to(#{p}_url) }
      format.xml  { head :ok }
    end
  end
end
TEMPLATE
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
    f.write "index page"
    f.close
    f = File.new("#{view_dir}show.html.erb", "w") 
    f.write "show page"
    f.close
    f = File.new("#{view_dir}new.html.erb", "w")
    f.write "<%= render :partial => '#{p}/form', :object => @#{s} %>"
    f.close
    f = File.new("#{view_dir}edit.html.erb", "w") 
    f.write "<%= render :partial => '#{p}/form', :object => @#{s} %>"
    f.close
    f = File.new("#{view_dir}_form.html.erb", "w")
    f.write "form text"
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

# m = Model.make_model_class :users
# b = Model.make_model_class :blogs
# m.has_many(b)

@app = App.new(nil)

def generate(*args)
  @app.generate(*args)
end

def route(*args)
  @app.route_args(*args)
end
