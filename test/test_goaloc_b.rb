require File.dirname(__FILE__) + '/test_helper.rb'

class TestGoalocB < Test::Unit::TestCase
  def clean_app!
    if defined?(@app)
      @app.models.values.each do |m|
        Object.send(:remove_const, m.to_s.to_sym)
      end
    end
    @app = App.new
  end
  
  context "that routes a highly complex route" do
    setup { clean_app!;  @app.route( [:users, :profiles, [:posts, [:comments, :ratings]], [:pictures, :ratings]]) }
    
    should "have routes on User" do
      assert_equal User.routes, [[User]]
    end
    
    should "have routes on Profiles" do
      assert_equal Profile.routes, [[User, Profile]]
    end
    
    should "have routes on Posts" do
      assert_equal Post.routes, [[User, Post]]  #this breaks for some reason that I don't understand.
    end
  end
end
