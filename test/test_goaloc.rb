require File.dirname(__FILE__) + '/test_helper'

class TestGoaloc < Test::Unit::TestCase
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

        should "return correct strings for the various rails helper functions" do
          assert_equal User.rails_symname, "@user"
          assert_equal User.rails_plural_symname, "@users"
          assert_equal User.rails_ivar_tuple, ["@user"]
          assert_equal User.rails_underscore_tuple, ["user"]
          assert_equal User.rails_object_path, "user_path(@user)"
          assert_equal User.rails_object_path(''), "user_path(user)"
          assert_equal User.rails_edit_path, "edit_user_path(@user)"
          assert_equal User.rails_edit_path(''), "edit_user_path(user)"
          assert_equal User.rails_new_path, "new_user_path()"
          assert_equal User.rails_collection_path, "users_path()"
          assert_equal User.nested?, false
          assert_equal User.rails_find_method, "  def find_user\n    @user = User.find(params[:id])\n  end"
          assert_equal User.rails_new_object_method, "  def new_user\n    @user = User.new(params[:user])\n  end"
          assert_equal User.rails_find_collection_method, "  def find_users\n    @users = User.find(:all)\n    @user = User.new(params[:user])\n  end"
          assert_equal User.rails_collection_finder_string, "@users = User.find(:all)"
          assert_equal User.rails_finder_string, "@user = User.find(params[:user_id])"
          assert_equal User.rails_new_object_string, "@user = User.new(params[:user])"
        end
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

      context "and has extended RailsModel" do
        setup { [Post, Comment].map { |x| x.class_eval "extend Rails::RailsModel"}}
        
        should "return correct strings for the various rails helper functions" do
          assert_equal Post.rails_symname, "@post"
          assert_equal Post.rails_plural_symname, "@posts"
          assert_equal Post.rails_ivar_tuple, ["@post"]
          assert_equal Post.rails_underscore_tuple, ["post"]
          assert_equal Post.rails_object_path, "post_path(@post)"
          assert_equal Post.rails_object_path(''), "post_path(post)"
          assert_equal Post.rails_edit_path, "edit_post_path(@post)"
          assert_equal Post.rails_edit_path(''), "edit_post_path(post)"
          assert_equal Post.rails_new_path, "new_post_path()"
          assert_equal Post.rails_collection_path, "posts_path()"
          assert_equal Post.nested?, false
          assert_equal Post.rails_find_method, "  def find_post\n    @post = Post.find(params[:id])\n  end"
          assert_equal Post.rails_new_object_method, "  def new_post\n    @post = Post.new(params[:post])\n  end"
          assert_equal Post.rails_find_collection_method, "  def find_posts\n    @posts = Post.find(:all)\n    @post = Post.new(params[:post])\n  end"
          assert_equal Post.rails_collection_finder_string, "@posts = Post.find(:all)"
          assert_equal Post.rails_finder_string, "@post = Post.find(params[:post_id])"
          assert_equal Post.rails_new_object_string, "@post = Post.new(params[:post])"
        end
      end
    end
    
    context "that routes a highly complex route" do
      setup { clean_app!;  @app.route( [:applications, :profiles, [:blogposts, :blogcomments]]) }
      
      should "have routes on Application" do
        assert_equal Application.routes, [[Application]]
      end
      
      should "have routes on Profiles" do
        assert_equal Profile.routes, [[Application, Profile]]
      end
      
      should "have routes on Blogposts" do
        assert_equal Blogpost.routes, [[Application, Blogpost]]  #this breaks for some reason that I don't understand.
      end

      context "and has extended RailsModel" do
        setup { [Application, Profile, Blogpost, Blogcomment].map { |x| x.class_eval "extend Rails::RailsModel"}}
        
        should "return correct strings for the various rails helper functions on Application" do
          assert_equal Application.rails_symname, "@application"
          assert_equal Application.rails_plural_symname, "@applications"
          assert_equal Application.rails_ivar_tuple, ["@application"]
          assert_equal Application.rails_underscore_tuple, ["application"]
          assert_equal Application.rails_object_path, "application_path(@application)"
          assert_equal Application.rails_object_path(''), "application_path(application)"
          assert_equal Application.rails_edit_path, "edit_application_path(@application)"
          assert_equal Application.rails_edit_path(''), "edit_application_path(application)"
          assert_equal Application.rails_new_path, "new_application_path()"
          assert_equal Application.rails_collection_path, "applications_path()"
          assert_equal Application.nested?, false
          assert_equal Application.rails_find_method, "  def find_application\n    @application = Application.find(params[:id])\n  end"
          assert_equal Application.rails_new_object_method, "  def new_application\n    @application = Application.new(params[:application])\n  end"
          assert_equal Application.rails_find_collection_method, "  def find_applications\n    @applications = Application.find(:all)\n    @application = Application.new(params[:application])\n  end"
          assert_equal Application.rails_collection_finder_string, "@applications = Application.find(:all)"
          assert_equal Application.rails_finder_string, "@application = Application.find(params[:application_id])"
          assert_equal Application.rails_new_object_string, "@application = Application.new(params[:application])"
        end

        should "return correct strings for the various rails helper functions on Blogcomment" do
          assert_equal Blogcomment.rails_symname, "@blogcomment"
          assert_equal Blogcomment.rails_plural_symname, "@blogcomments"
          assert_equal Blogcomment.rails_ivar_tuple, ["@application", "@blogpost", "@blogcomment"]
          assert_equal Blogcomment.rails_underscore_tuple, ["application", "blogpost", "blogcomment"]
          assert_equal Blogcomment.rails_object_path, "application_blogpost_blogcomment_path(@application, @blogpost, @blogcomment)"
          assert_equal Blogcomment.rails_object_path(''), "application_blogpost_blogcomment_path(@application, @blogpost, blogcomment)"
          assert_equal Blogcomment.rails_edit_path, "edit_application_blogpost_blogcomment_path(@application, @blogpost, @blogcomment)"
          assert_equal Blogcomment.rails_edit_path(''), "edit_application_blogpost_blogcomment_path(@application, @blogpost, blogcomment)"
          assert_equal Blogcomment.rails_new_path, "new_application_blogpost_blogcomment_path(@application, @blogpost)"
          assert_equal Blogcomment.rails_collection_path, "application_blogpost_blogcomments_path(@application, @blogpost)"
          assert_equal Blogcomment.nested?, true
          assert_equal Blogcomment.rails_find_method, "  def find_blogcomment\n    @application = Application.find(params[:application_id])\n    @blogpost = @application.blogposts.find(params[:blogpost_id])\n    @blogcomment = @blogpost.blogcomments.find(params[:id])\n  end"
          assert_equal Blogcomment.rails_new_object_method, "  def new_blogcomment\n    @application = Application.find(params[:application_id])\n    @blogpost = @application.blogposts.find(params[:blogpost_id])\n    @blogcomment = Blogcomment.new((params[:blogcomment] or {}).merge({:blogpost => @blogpost}))\n  end"
          assert_equal Blogcomment.rails_find_collection_method, "  def find_blogcomments\n    @application = Application.find(params[:application_id])\n    @blogpost = @application.blogposts.find(params[:blogpost_id])\n    @blogcomments = @blogpost.blogcomments\n    @blogcomment = Blogcomment.new((params[:blogcomment] or {}).merge({:blogpost => @blogpost}))\n  end"
          assert_equal Blogcomment.rails_collection_finder_string, "@blogcomments = @blogpost.blogcomments"
          assert_equal Blogcomment.rails_finder_string, "@blogcomment = @blogpost.blogcomments.find(params[:blogcomment_id])"
          assert_equal Blogcomment.rails_new_object_string, "@blogcomment = Blogcomment.new((params[:blogcomment] or {}).merge({:blogpost => @blogpost}))"
        end
      end
    end
  end
end
