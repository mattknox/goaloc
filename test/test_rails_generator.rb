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
  
  context "a rails generator with a nontrivial goal" do
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
    
    should_eventually "produce a valid string for the controller" do
      assert_match /def find_post/, @generator.gen_controller_str(@app.goals["comment"])
    end
    
    should "produce a valid string for the index view"
    should "produce a valid string for the show view"
    should "produce a valid string for the _model view"
    should "produce a valid string for the _model_small view"
    should "produce a valid string for the _form view"
    should "produce a valid string for the edit view"
    should "produce a valid string for the new view"
    should "produce a valid string for the view layout"
  end
end
