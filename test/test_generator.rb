require File.dirname(__FILE__) + '/test_helper'

class TestGenerator < Test::Unit::TestCase
  context "the base generator" do
    setup do
      @app = App.new
      @generator = Generator.new(@app, Rails)
    end
    
    should "have an app" do
      assert @generator.app
    end
    
    should_eventually "have a generate method" do
      assert @generator.respond_to?(:generate)
    end
    
    should "have a generate_all method" do
      assert Generator.respond_to?(:generate_all)
    end
  end
end
