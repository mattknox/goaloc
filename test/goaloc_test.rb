require File.dirname(__FILE__) + '/test_helper'

class GoalocTest < Test::Unit::TestCase
  def clean_app!
    if defined?(@app)
      @app.models.values.each do |m|
        Object.send(:remove_const, m.to_s.to_sym)
      end
    end
    @app = App.new
  end
  
  context "an app" do
    setup { clean_app! }
    
    should "route a single symbol" do
      assert @app.route(:users)
    end
    
    context "that called route :users " do
      setup { clean_app!; @app.route(:users) }
      
      should "have nonempty routes" do
        assert !@app.routes.empty?
      end
      
      should "include a route that is just :users" do
        assert @app.routes.member?(:users)
      end
      
      should "define User class" do
        assert defined?(User)
      end
      
      should "have routes on User" do
        assert_equal User.routes, [[User]]
      end
      
      context "and User.add_attrs" do
        setup { User.add_attrs("name:string email:str age:int ssn:integer dead:boolean cute:bool") }
        
        should "map all six given attrs" do
          assert !User.fields.empty?
          assert_equal "string", User.fields["name"]
          assert_equal "string", User.fields["email"]
          assert_equal "integer", User.fields["age"]
          assert_equal "integer", User.fields["ssn"]
          assert_equal "boolean", User.fields["dead"]
          assert_equal "boolean", User.fields["cute"]
        end
      end

      context "and has extended RailsModel" do
        setup { User.class_eval "extend Rails::RailsModel"}

        should "have a "
      end
    end
    
    context "that routes a nested route" do
      setup { clean_app!; @app.route([:posts, :comments])}
      
      should "define a nested route" do
        assert @app.routes.member?([:posts, :comments])
      end
      
      should "define Post and Comment"do
        assert defined?(Post)
        assert defined?(Comment)
      end
      
      should "define a simple Post route" do
        assert_equal Post.routes, [[Post]]
      end
      
      should "define a nested Comment route" do
        assert_equal Comment.routes, [[Post, Comment]]
      end
      
      should "make an association from Post to Comment" do
        assert_equal "comments", Post.associations.keys.first
      end
      
      should "make an association from Comment to Post" do
        assert_equal "post", Comment.associations.keys.first
      end
      
      should "set a foreign key on comment" do
        assert_equal "post_id", Comment.foreign_keys.first
      end
    end
    
    context "that routes a highly complex route" do
      setup { clean_app!;  @app.route( [:applications, :profiles, [:blogposts, [:blogcomments, :ratings]], [:pictures, :ratings]]) }
      
      should "have routes on User" do
        assert_equal Application.routes, [[Application]]
      end
      
      should "have routes on Profiles" do
        assert_equal Profile.routes, [[Application, Profile]]
      end
      
      should "have routes on Posts" do
        assert_equal Blogpost.routes, [[Application, Blogpost]]  #this breaks for some reason that I don't understand.
      end
    end
  end
end
