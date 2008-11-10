require File.dirname(__FILE__) + '/test_helper.rb'

class TestGoalocA < Test::Unit::TestCase
  def clean_app!
    if defined?(@app)
      @app.models.values.each do |m|
        Object.send(:remove_const, m.to_s.to_sym)
      end
    end
    @app = App.new
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
end
