require File.dirname(__FILE__) + '/test_helper'

class TestApp < Test::Unit::TestCase
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
    end

    context "on which route :posts has been called " do
      setup { @app.route :posts }

      should "have routes on itself and its goal" do 
        assert_equal @app.routes, [:posts]
        assert_equal @app.goals[:post].routes, [[:posts]]
        assert_match "route :posts", @app.goaloc_log.first
      end

      should "have a resource tuple" do
        assert_equal @app.goals[:post].resource_tuple, [:posts]
      end

      should "have a generate method"
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
        @app.add_attrs :posts => "name:string body:text"
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
        assert_equal @app.goals[:post].routes, [[:posts]]
        assert_equal @app.goals[:comment].routes, [[:comments]]
        assert_equal @app.goals[:user].routes, [[:users]]
      end

      should "have resource tuples on all its goals" do
        assert_equal @app.goals[:post].resource_tuple, [:posts]
        assert_equal @app.goals[:comment].resource_tuple, [:comments]
        assert_equal @app.goals[:user].resource_tuple, [:users]
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
        assert_equal @app.goals[:user].routes, [[:users]]
        assert_equal @app.goals[:name].routes, [[:names]]
        assert_equal @app.goals[:post].routes, [[:posts]]
        assert_equal @app.goals[:comment].routes, [[:posts, :comments]]
        assert_equal @app.goals[:postbundle].routes, [[:posts, :postbundle]]
      end

      should "have resource tuples on all its goals" do
        assert_equal @app.goals[:user].resource_tuple, [:users]
        assert_equal @app.goals[:name].resource_tuple, [:names]
        assert_equal @app.goals[:post].resource_tuple, [:posts]
        assert_equal @app.goals[:comment].resource_tuple, [:posts, :comments]
        assert_equal @app.goals[:postbundle].resource_tuple, [:posts, :postbundle]
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
end
