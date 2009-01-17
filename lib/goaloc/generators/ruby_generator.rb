class RubyGenerator < Generator
  module RubyGoal
    # this is mixed into a goal to provide it with convenience methods for generating ruby code.
    def ruby_ivar_name
      "@" + self.name
    end

    def ruby_plural_ivar_name
      ruby_ivar_name.pluralize
    end

    def rails_ivar_tuple(end_index = -1)
      self.resource_tuple[0..end_index].map {|c| c.rails_symname }
    end
  end
end
