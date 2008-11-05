class Model  
  def Model.build_and_route(name, route)
    x = Model.make_model_class(name)
    x.routes << (route.to_a.clone << x)
    x
  end

  def Model.db_type_map
    { 
      "str" => "string", "string" => "string", "s" => "string",
      "int" => "integer", "integer" => "integer", "i" => "integer",
      "bool" => "boolean", "boolean" => "boolean", "b" => "boolean",
      "text" => "text", "t" => "text"
    }
  end
  
  def Model.make_model_class(name)
    # routes is the set of urls by which you can get to an instance of a class
    Object.class_eval "
    class #{ name.to_s.singularize.camelize} < Model
      cattr_accessor :associations, :fields, :options, :routes, :foreign_keys, :validations
      self.associations = { }
      self.fields = { }
      self.options = { }
      self.routes = [] # of the form [:classname, [:otherclass, :classname], ...]
      self.foreign_keys = []
      self.validations = { }

      class << self
        def cs
          self.to_s
        end

        def cp
          self.to_s.pluralize
        end

        def s
          self.to_s.underscore
        end

        def p
          self.to_s.underscore.pluralize
        end
      end
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

    def has_many(m, o = { })
      associate(:has_many, m, o)
      m.associate(:belongs_to, self, o) unless o[:skip_belongs_to]
    end

    def has_one(m, o = { })
      associate(:has_one, m, o)
      m.associate(:belongs_to, self, o) unless o[:skip_belongs_to]
    end

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
      self.fields[name] = Model.db_type_map[field_type]
    end
  end
end
