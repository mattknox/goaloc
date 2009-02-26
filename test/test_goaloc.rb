require File.dirname(__FILE__) + '/test_helper'
require File.dirname(__FILE__) + '/../lib/goaloc.rb'

class TestGoaloc < Test::Unit::TestCase
  context "the core goaloc class" do
    
    should "have a working reset method" do
      old_app = APP
      Object.send(:reset)
      assert_not_equal old_app, @app
    end
  end
end
