require File.dirname(__FILE__) + '/test_helper'

class TestGoaloc < Test::Unit::TestCase
  context "an app" do
    setup { @app = App.new }

    should "route a single symbol" do
      assert @app.respond_to? :route
      assert @app.route(:posts)
    end
  end
  
  context "a Goal" do 
    setup { @goal = Goal.new("goal1") }
    should "have attr_accessor'd attrs" do
      [:associations, :validations, :fields, :options, :routes].each do |sym|
        assert @goal.respond_to? sym
        assert @goal.respond_to? sym.to_s + "="
      end
    end

    should "have a name" do
      assert @goal.respond_to? :name
      assert !(@goal.respond_to? "name=")
    end
    
    context "#belongs_to method" do
      setup do
        @goal1 = Goal.new("goal1")
        @goal2 = Goal.new("goal2")
        @goal1.belongs_to @goal2
      end
      
      should "put an assoc in the associations instance var" do
        assert !@goal1.associations[@goal2.name].blank?
        assert @goal1.associations[@goal2.name][:goal] == @goal2
      end

      should "set a foreign key" do
        assert !@goal1.fields[@goal2.foreign_key].blank?
        assert @goal1.fields[@goal2.foreign_key] == "reference"
      end
    end

    context "#has_many method" do
      setup do
        @goal1 = Goal.new("goal1")
        @goal2 = Goal.new("goal2")
        @goal1.has_many @goal2
      end
      
      should "put an assoc in the associations instance var" do
        assert !@goal1.associations.empty?
        assert @goal1.associations[@goal2.name.pluralize][:goal] == @goal2
      end
    end

    context "#has_one method" do
      setup do
        @goal1 = Goal.new("goal1")
        @goal2 = Goal.new("goal2")
        @goal1.has_one @goal2
      end
      
      should "put an assoc in the associations instance var" do
        assert !@goal1.associations.empty?
        assert @goal1.associations[@goal2.name][:goal] == @goal2
      end
    end
  end
end
