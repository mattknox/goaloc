require File.dirname(__FILE__) + '/test_helper'

class TestGenerator < Test::Unit::TestCase
  context "the base generator" do
    setup do
      @app = App.new
      @generator = Generator.build(@app, Rails)
    end

    should "raise an exception if it tries to build a generator for a backend that doesn't exist." do
      assert_raise RuntimeError do
        Generator.build(@app, Object)
      end
    end
    
    should "have a generate method" do
      assert @generator.respond_to?(:generate)
    end
    
    should_eventually "have a generate_all method" do
      assert Generator.respond_to?(:generate_all)
    end
  end
end
