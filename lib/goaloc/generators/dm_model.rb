class DmModel
  # this class generates DataMapper models

  FIELD_TYPE_MAP = {
    "integer" => "Integer",
    "string" => "String",
    "text" => "Text",
    "serial" => "Serial",
    "datetime" => "DateTime"
  }
  def DmModel.field_type(s)
    FIELD_TYPE_MAP[s]
  end
  
  def DmModel.property_string(name, typestring)
    "property :#{name}, #{DmModel.field_type(typestring)}"
  end
end
