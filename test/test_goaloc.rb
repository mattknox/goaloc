require File.dirname(__FILE__) + '/test_helper.rb'

class TestGoaloc < Test::Unit::TestCase

#     context "that routes a nested route" do
#       setup { clean_app!; @app.route([:posts, :comments])}

#       should "define a nested route" do
#         assert @app.routes.member?([:posts, :comments])
#       end
      
#       should "define Post and Comment"do
#         assert defined?(Post)
#         assert defined?(Comment)
#       end

#       should "define a simple Post route" do
#         assert_equal Post.routes, [[Post]]
#       end

#       should "define a simple Comment route" do
#         assert_equal Comment.routes, [[Post, Comment]]
#       end

#       should "make an association from Post to Comment" do
#         assert_equal "comments", Post.associations.keys.first
#       end

#       should "make an association from Comment to Post" do
#         assert_equal "post", Comment.associations.keys.first
#       end

#       should "set a foreign key on comment" do
#         assert_equal "post_id", Comment.foreign_keys.first
#       end
#     end

#     context "that routes a highly complex route" do
#       setup { clean_app!;  @app.route( [:users, :profiles, [:posts, [:comments, :ratings]], [:pictures, :ratings]]) }

#       should "have routes on User" do
#         assert_equal User.routes, [[User]]
#       end

#       should "have routes on Profiles" do
#         assert_equal Profile.routes, [[User, Profile]]
#       end

#       should "have routes on Posts" do
#         assert_equal Post.routes, [[User, Post]]
#       end
#     end
end
