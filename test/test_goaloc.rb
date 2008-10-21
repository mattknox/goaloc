require File.dirname(__FILE__) + '/test_helper.rb'

class TestGoaloc < Test::Unit::TestCase
  context "an app" do
    setup { @app = App.new }
    
    should "route a single symbol" do
      assert @app.route_args(:users)
    end

    context "that has successfully called route" do
      setup { @app.route_args(:users) }
      
      should "have nonempty routes" do
        assert !@app.routes.empty?
      end

      should "include a route that is just :users" do
        assert @app.routes.member?(:users)
      end
      
      should "define User class" do
        
      end
    end

    context "that routes a nested route" do
      setup { @app.route_args([:posts, :comments])}

      should "define Post and Comment"do
        assert defined?(Post)
        assert defined?(Comment)
      end

      should "make an association from Post to Comment" do
        assert_equal "comments", Post.associations.keys.first
      end

      should "make an association from Comment to Post" do
        assert_equal "post", Comment.associations.keys.first
      end
    end
  end
end
