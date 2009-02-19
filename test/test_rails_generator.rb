require File.dirname(__FILE__) + '/test_helper'

class TestRailsGenerator < Test::Unit::TestCase
  context "a rails generator with one empty goal" do
    setup do
      @app = App.new("foobar")
      @app.route :posts
      @generator = @app.generator(Rails)
    end

    should "have a generate method" do
      assert @generator.respond_to?(:generate)
    end
    
    should "have a method to produce a route string" do
      assert @generator.respond_to?(:gen_routes_string)
    end
    
    should "produce a valid string for generate routes" do
      assert_match "map.resources :posts", @generator.gen_routes_string
      assert_match "map.root :controller => 'posts'", @generator.gen_routes_string
    end
  end
  
  context "a rails generator with a nested route " do
    setup do
      @app = App.new("foobar")
      @app.route [:posts, :comments]
      @generator = @app.generator(Rails)
    end

    should "produce a valid route string" do 
      assert_match "map.resources :posts do |post|", @generator.gen_routes_string
      assert_match "post.resources :comments", @generator.gen_routes_string
      assert_match "map.root :controller => 'posts'", @generator.gen_routes_string
    end
  end

  context "a rails generator with a rootless route " do
    setup do
      @app = App.new("foobar")
      @app.route [:posts, :comments], :pictures
      @generator = @app.generator(Rails)
    end

    should "produce a valid route string" do 
      assert_match "map.resources :posts do |post|", @generator.gen_routes_string
      assert_match "map.resources :pictures", @generator.gen_routes_string
      assert_match "post.resources :comments", @generator.gen_routes_string
      assert_no_match /map.root :controller => 'posts'/, @generator.gen_routes_string
    end
  end
  
  context "a rails generator with nested nontrivial goals" do
    setup do
      @app = App.new("foobar")
      @app.route [:posts, :comments], :pictures
      @app.add_attrs :posts => "body:text title:string", :comments => "body:text", :pictures => "rating:integer"
      @generator = @app.generator(Rails)
    end

    should "generate valid routes" do
      assert_match /map.resources :posts/, @generator.gen_routes_string
    end

    should "generate correct collection_path" do
      assert_equal "post_comments_path(@post)", @generator.collection_path(Comment)
    end
    
    should "produce a valid migration"do
      assert_match /text :body/, @generator.gen_string("migration", Post)
    end

    should "produce a valid string for the model" do
      assert_match /class Post < ActiveRecord::Base/, @generator.gen_model_str(@app.goals["post"])
      assert_match /has_many :comments/, @generator.gen_model_str(@app.goals["post"])
      assert_match /belongs_to :post/, @generator.gen_model_str(@app.goals["comment"])
      assert_match /validates_presence_of :post/, @generator.gen_model_str(@app.goals["comment"])
    end
    
    should "produce a valid string for the controller" do
      assert_match /def find_comment/, @generator.gen_string("controller", @app.goals["comment"])
      assert_match /def find_post/, @generator.gen_string("controller", @app.goals["post"])
    end
    
    should "produce a valid string for the index view" do
      assert_match /render :partial => 'comments\/comment', :collection => @comments/, @generator.gen_string("index", @app.goals["comment"])
    end
    
    should "produce a valid string for the show view" do
      assert_match /render :partial => 'comments\/comment', :object => @comment/, @generator.gen_string("show", @app.goals["comment"])
    end
    
    should "produce a valid string for the _model view" do
      assert_match /div_for\(post\) do /, @generator.gen_string("_model", @app.goals["post"])
      #assert_match /render :partial => 'comments\/comment', :object => @comment/, @generator.gen_partial_str(@app.goals["post"])
    end
    
    should "produce a valid string for the _model_small view" do
      assert_match /div_for\(post_small\) do /, @generator.gen_string("_model_small", @app.goals["post"])
    end
    
    should "produce a valid string for the _form view" do 
      assert_match /form_for..form/, @generator.gen_string("_form", @app.goals["post"])
    end

    should "produce a valid string for the edit view" do 
      assert_match /render :partial => 'comments\/form', :object => @comment/, @generator.gen_edit_str(@app.goals["comment"])
    end
    
    should "produce a valid string for the new view" do 
      assert_match /render :partial => 'comments\/form', :object => @comment/, @generator.gen_new_str(@app.goals["comment"])
    end

    should "produce a valid string for the unit test"
    should "produce a valid string for the functional test" do
      #assert_match /xzy/, @generator.gen_controller_test_string(Comment)
    end

    should_eventually "produce a valid string for the view layout" do
      # the layout is presently copied, not generated through ERB.  
      assert_match /<html/, @generator.gen_layout_str
      assert_match /<\/html>/, @generator.gen_layout_str
      assert_match /<\/head>/, @generator.gen_layout_str
      assert_match /yield /, @generator.gen_layout_str
    end

    should "generate an app_name, possibly with a suffix" do
      assert_equal @generator.app_name, "foobar"
      @generator.opts[:base_dir_suffix] = true
      assert_equal @generator.app_name, "foobar_rails"
    end

    should "have an app_dir, possibly with a root dir"do
      assert_equal @generator.app_dir, "foobar"
      @generator.root_dir = "blah"
      assert_equal @generator.app_dir, "blah/foobar"
    end
    
    context "and cleaned out tmp directory" do
      setup do
        @tmp_dir = File.join(File.dirname(__FILE__), 'tmp')
        @generator.root_dir = @tmp_dir
        FileUtils.rm_rf(@tmp_dir)
        
        assert ! File.exists?(@tmp_dir)
        @generator.generate
        assert File.exists?(@tmp_dir)
      end
      
      teardown do
        FileUtils.rm_rf(@tmp_dir)
      end
      
      should "generate a rails app skeleton" do
        assert File.exists?(@tmp_dir + "/foobar") # checking a random selection of generated rails files.
        assert File.exists?(@tmp_dir + "/foobar/config")
        assert File.exists?(@tmp_dir + "/foobar/app")
        assert File.exists?(@tmp_dir + "/foobar/db")
        assert File.exists?(@tmp_dir + "/foobar/db/migrate")
      end
      
      should "generate a bunch of migrations on" do
        [:posts, :comments, :pictures].each do |x|
          assert !Dir.glob("#{@tmp_dir}/foobar/db/migrate/*#{x.to_s}*").blank?
        end
      end

      should "generate model files" do 
        [:posts, :comments, :pictures].each do |x|
          assert File.exists?("#{@tmp_dir}/foobar/app/models/#{x.to_s.singularize}.rb")
        end
      end

      should "generate controller files" do 
        [:posts, :comments, :pictures].each do |x|
          assert File.exists?("#{@tmp_dir}/foobar/app/controllers/#{x}_controller.rb")
        end
      end

      should "generate view files" do 
        [:posts, :comments, :pictures].each do |x|
          assert File.exists?("#{@tmp_dir}/foobar/app/views/#{x}/show.html.erb")
          assert File.exists?("#{@tmp_dir}/foobar/app/views/#{x}/index.html.erb")
          assert File.exists?("#{@tmp_dir}/foobar/app/views/#{x}/edit.html.erb")
          assert File.exists?("#{@tmp_dir}/foobar/app/views/#{x}/new.html.erb")
          assert File.exists?("#{@tmp_dir}/foobar/app/views/#{x}/_form.html.erb")
          assert File.exists?("#{@tmp_dir}/foobar/app/views/#{x}/_#{x.to_s.singularize}_small.html.erb")
          assert File.exists?("#{@tmp_dir}/foobar/app/views/#{x}/_#{x.to_s.singularize}.html.erb")
        end
      end

      should "generate test files" do
        [:posts, :comments, :pictures].each do |x|
          assert File.exists?("#{@tmp_dir}/foobar/test/unit/#{x.to_s.singularize}_test.rb")
          assert File.exists?("#{@tmp_dir}/foobar/test/functional/#{x}_controller_test.rb")
        end
      end

      should "make a rails project that passes tests" do
        current_dir = `pwd`.chomp
        FileUtils.cd @generator.app_dir
        `rake db:create:all`
        `rake db:migrate`
        s = `rake test`
        assert_match /0 failures, 0 errors/, s
        `rake db:drop:all`
        FileUtils.cd current_dir
      end
    end
  end
end
