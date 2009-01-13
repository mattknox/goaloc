require File.dirname(__FILE__) + '/test_helper'

class TestGoaloc < Test::Unit::TestCase
  context "an app" do
    setup { @app = App.new }

    should "have a settable name" do
      assert @app.name
      @app.name = "foobar"
      assert_equal "foobar", @app.name
    end
    
    should "route a single symbol" do
      assert @app.respond_to? :route
      assert @app.route(:posts)
      assert_equal @app.routes, [:posts]
    end

    should "route a number of sequential symbols, like :posts, :comments"
    should "route nested arrays of symbols, like [:posts, :comments] or [:users, [:posts, :comments]]"
    
    context "#route method" do
      should "return nil if called without args" do
        assert_equal nil, @app.route
        assert_equal nil, @app.route
      end
    end
  end

  context "a named app" do
    setup { @app = App.new("foobar")}

    should "have the set name" do
      assert_equal "foobar", @app.name
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
