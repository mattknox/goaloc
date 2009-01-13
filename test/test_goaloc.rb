require File.dirname(__FILE__) + '/test_helper'

class TestGoaloc < Test::Unit::TestCase
  context "an app" do
    setup { @app = App.new }

    should "have a settable name" do
      assert @app.name
      @app.name = "foobar"
      assert_equal "foobar", @app.name
    end
    
    should "return nil if called without args" do
      assert_equal nil, @app.route
    end

    should "route a single symbol" do
      assert @app.respond_to? :route
      assert @app.route(:posts)
      assert_equal @app.routes, [:posts]
    end

    context "when routing a single symbol" do
      setup { @app.route(:posts)}

      should "have a goal named post" do
        assert !@app.goals.empty?
        assert_equal @app.goals[:post].class, Goal
        assert_equal @app.goals[:post].name, "post"
      end

      should "add fields with add_attrs" do
        assert @app.goals[:post].fields.empty?
        @app.goals[:post].add_attrs "name:string body:text"
        assert !@app.goals[:post].fields.empty?
        assert_equal @app.goals[:post].fields[:name], "string"
        assert_equal @app.goals[:post].fields[:body], "text"
      end
    end

    context "route a number of sequential symbols, like :posts, :comments" do
      setup { @app.route(:posts, :comments, :users) }

      %w{ post comment user }.each do |word|
        should "have a goal named #{word}" do
          assert !@app.goals.empty?
          assert_equal @app.goals[word].class, Goal
          assert_equal @app.goals[word].name, word
        end
      end

      should "have routes" do
        assert_equal @app.routes, [:posts, :comments, :users]
      end
    end

    context  "route nested arrays of symbols, like [:posts, :comments] or [:users, [:posts, :comments]]" do
      setup { @app.route(:users, :names, [:posts, :comments, :postbundle]) }

      %w{ post comment }.each do |word|
        should "have a goal named #{word}" do
          assert !@app.goals.empty?
          assert_equal @app.goals[word].class, Goal
          assert_equal @app.goals[word].name, word
        end

        should "have associations defined by the nesting" do
          assert !@app.goals[:post].associations.blank?
          assert @app.goals[:post].associations.is_a? Hash
          assert @app.goals[:post].associations[:comments].is_a? Hash
          assert_equal @app.goals[:post].associations[:comments][:goal], @app.goals[:comment]
          assert_equal @app.goals[:post].associations[:comments][:type], :has_many
          assert_equal @app.goals[:comment].associations[:post][:goal], @app.goals[:post]
          assert_equal @app.goals[:comment].associations[:post][:type], :belongs_to
          assert_equal @app.goals[:post].associations[:postbundle][:goal], @app.goals[:postbundle]
          assert_equal @app.goals[:post].associations[:postbundle][:type], :has_one 
          assert_equal @app.goals[:postbundle].associations[:post][:goal], @app.goals[:post]
          assert_equal @app.goals[:postbundle].associations[:post][:type], :belongs_to 
        end
      end

      should "have routes" do
        assert_equal @app.routes, [:users, :names, [:posts, :comments, :postbundle]]
      end
    end

    context "when adding attrs" do
      setup do
        @app.route 
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
  end
end
