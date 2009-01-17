require File.dirname(__FILE__) + '/test_helper'

class TestRailsGenerator < Test::Unit::TestCase
  context "a rails generator with one empty goal" do
    setup do
      @app = App.new
      @app.route :posts
      @generator = @app.generate(Rails)
    end

    should "have a generate method" do
      assert @generator.respond_to?(:generate)
    end
    
    should "have a method to produce a route string" do
      assert @generator.respond_to?(:gen_route_string)
    end
    
    should "produce a valid string for generate routes" do
      assert_match "map.resources :posts", @generator.gen_route_string
      assert_match "map.root :controller => 'posts'", @generator.gen_route_string
    end
  end

  context "a rails generator with a nested route " do
    setup do
      @app = App.new
      @app.route [:posts, :comments]
      @generator = @app.generate(Rails)
    end

    should "produce a valid route string" do 
      assert_match "map.resources :posts do |post|", @generator.gen_route_string
      assert_match "post.resources :comments", @generator.gen_route_string
      assert_match "map.root :controller => 'posts'", @generator.gen_route_string
    end
  end

  context "a rails generator with a rootless route " do
    setup do
      @app = App.new
      @app.route [:posts, :comments], :pictures
      @generator = @app.generate(Rails)
    end

    should "produce a valid route string" do 
      assert_match "map.resources :posts do |post|", @generator.gen_route_string
      assert_match "map.resources :pictures", @generator.gen_route_string
      assert_match "post.resources :comments", @generator.gen_route_string
      assert_no_match /map.root :controller => 'posts'/, @generator.gen_route_string
    end
  end
  
  context "a rails generator with nested nontrivial goals" do
    setup do
      @app = App.new
      @app.route [:posts, :comments], :pictures
      @app.add_attrs :posts => "body:text title:string", :comments => "body:text", :pictures => "rating:integer"
      @generator = @app.generate(Rails)
    end
    
    should "produce a valid string for the model" do
      assert_match /class Post < ActiveRecord::Base/, @generator.gen_model_str(@app.goals["post"])
      assert_match /has_many :comments/, @generator.gen_model_str(@app.goals["post"])
      assert_match /belongs_to :post/, @generator.gen_model_str(@app.goals["comment"])
      assert_match /validates_presence_of :post/, @generator.gen_model_str(@app.goals["comment"])
    end
    
    should "produce a valid string for the controller" do
      assert_match /def find_comment/, @generator.gen_controller_str(@app.goals["comment"])
    end
    
    should "produce a valid string for the index view" do
      assert_match /render :partial => 'comments\/comment', :collection => @comments/, @generator.gen_index_str(@app.goals["comment"])
    end
    
    should "produce a valid string for the show view" do
      assert_match /render :partial => 'comments\/comment', :object => @comment/, @generator.gen_show_str(@app.goals["comment"])
    end
    
    should "produce a valid string for the _model view" do
      assert_match /div_for\(post\) do /, @generator.gen_partial_str(@app.goals["post"])
      #assert_match /render :partial => 'comments\/comment', :object => @comment/, @generator.gen_partial_str(@app.goals["post"])
    end
    
    should "produce a valid string for the _model_small view" do
      assert_match /div_for\(post_small\) do /, @generator.gen_partial_small_str(@app.goals["post"])
    end
    should "produce a valid string for the _form view" do 
      assert_match /form_for..form/, @generator.gen_form_str(@app.goals["post"])
    end

    should "produce a valid string for the edit view"
    should "produce a valid string for the new view"
    
    should "produce a valid string for the view layout" do
      assert_match /<html/, @generator.gen_layout_str
      assert_match /<\/html>/, @generator.gen_layout_str
      assert_match /<\/head>/, @generator.gen_layout_str
      assert_match /yield /, @generator.gen_layout_str
    end
  end
end
