require File.dirname(__FILE__) + '/test_helper'

class TestRailsGenerator < Test::Unit::TestCase
  context "a rails generator with one empty goal" do
    setup do
      @app = App.new
      @app.route :posts
      @generator = @app.generate(Rails)
    end
    
    should "produce a valid string for generate routes" do
      assert true
    end
  end

  context "a rails generator with a nontrivial goal" do
    should "produce a valid string for the model"
    should "produce a valid string for the controller"
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
