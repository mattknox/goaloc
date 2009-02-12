require File.dirname(__FILE__) + '/test_helper'

class TestGoal < Test::Unit::TestCase
  context "a Goal" do 
    setup { @goal = Goal.new("foo") }
    
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

    should "accept calls to validates" do
      @goal.validates(:presence_of, :foobar)
      assert !@goal.validations.blank?
      assert_equal @goal.validations.length, 1
      assert_equal @goal.validations.first[:val_type], :presence_of
      assert_equal @goal.validations.first[:field], :foobar
    end

    context "" do
      setup do
        @goal.routes << [:frob, :bar]
        @goal.routes << [:frob, :baz]
      end

      should "have a blank " do
        assert_equal @goal.resource_tuple, []
      end
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
        assert !@goal1.foreign_keys[@goal2.foreign_key].blank?
        assert @goal1.foreign_keys[@goal2.foreign_key] == "references"
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
        Goal.new("user")
        Goal.new("profile")
        User.has_one Profile
      end
      
      should "put an assoc in the associations instance var" do
        assert !User.associations.empty?
        assert User.associations[Profile.name][:goal] == Profile
      end
    end

    context "#hmt method" do
      setup do
        @goal1 = Goal.new("goal1")
        @goal2 = Goal.new("goal2")
        @goal3 = Goal.new("goal3")
        @goal1.hmt @goal2, :through => @goal3
      end

      should "put has_many, belongs_to, and has_many :through assocs in place" do
        assert !@goal1.associations.blank?
        assert @goal1.associations["goal2s"].is_a? Hash
        assert @goal1.associations["goal3s"].is_a? Hash # this is a has_many, so it's plural
        assert_equal @goal1.associations["goal2s"][:type], :has_many
        assert_equal @goal1.associations["goal2s"][:goal], @goal2
        assert_equal @goal1.associations["goal2s"][:through], @goal3
        assert_equal @goal1.associations["goal3s"][:type], :has_many
        assert_equal @goal1.associations["goal3s"][:goal], @goal3
        assert !@goal2.associations.blank?
        assert @goal2.associations["goal1s"].is_a? Hash
        assert @goal2.associations["goal3s"].is_a? Hash # this is a has_many, so it's plural
        assert_equal @goal2.associations["goal1s"][:type], :has_many
        assert_equal @goal2.associations["goal1s"][:goal], @goal1
        assert_equal @goal2.associations["goal1s"][:through], @goal3
        assert_equal @goal2.associations["goal3s"][:type], :has_many
        assert_equal @goal2.associations["goal3s"][:goal], @goal3
        assert !@goal3.associations.blank?
        assert @goal3.associations[:goal2].is_a? Hash
        assert @goal3.associations[:goal1].is_a? Hash
        assert_equal @goal3.associations[:goal1][:type], :belongs_to
        assert_equal @goal3.associations[:goal1][:goal], @goal1
        assert_equal @goal3.associations[:goal2][:type], :belongs_to
        assert_equal @goal3.associations[:goal2][:goal], @goal2
      end
    end

    context "add_attrs method" do
      %w{ - , . }.each_with_index do |str, i|
        should "strip a #{str} char out of a call to add_attrs" do
          keyname = ("attrname" + ("x" * i))
          @goal.add_attrs "#{keyname}:string#{str}"
          assert_equal @goal.fields[keyname], "string"
        end
      end
    end
  end
end
