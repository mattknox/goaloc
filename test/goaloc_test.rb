require "Shoulda"
class GoalocTest < Test::Unit
  
  context "goaloc" do
    setup do
      @app = App.new
    end

    should "route a pluralized symbol" do
      @app.route :users
      assert @app.routes.member? :users
    end
  end
  
end
