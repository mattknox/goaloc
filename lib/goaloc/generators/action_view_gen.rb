class ActionViewGen
  # move all of the ActionView stuff into here from rails.rb

  def ActionViewGen.field_string(name, type)
    case type
    when "text" then "    <%= f.text_area :#{name} %" + ">"
    when "foreign_key" then "    <%= f.select :#{name}, #{name[0..-4].camelize}.find(:all).map { |x| ['#{name}' + x.id.to_s, x.id]} %>"
    else "    <%= f.text_field :#{name} %" + ">"
    end
  end
end
