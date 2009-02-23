class ArModel
  # returns the rails string defining an association.  Supports belongs_to, has_many, hmt
  def ArModel.association_string(assoc_name, assoc_hash)
    option_str = assoc_hash[:through] ? ", :through => :#{assoc_hash[:through].p}"  : ""
    "#{assoc_hash[:type]} :#{assoc_name + option_str}"
  end
end
