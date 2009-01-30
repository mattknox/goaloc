require File.dirname(__FILE__) + '/test_helper'

class TestDmModel < Test::Unit::TestCase
  context "the property_string method" do
    setup {  @dm_model =  DmModel.new }
    should "generate correct property_strings" do
      { "datetime" => "DateTime", "integer" => "Integer",
        "string" => "String", "text" => "Text", "serial" => "Serial"}.each do |goaloc_type, dm_type|
        field_name = "ab" + ("C" * rand(10))
        assert_equal "property :#{field_name}, #{dm_type}", DmModel.property_string(field_name, goaloc_type)
      end
    end
  end
end
