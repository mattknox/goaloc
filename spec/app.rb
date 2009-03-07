require File.dirname(__FILE__) + '/../lib/goaloc'

describe App do
  before(:each) do
    @app = App.new
  end

  it "should route things" do
    @app.should respond_to :route
    @app.goals.length.should == 0
    @app.route [:posts, :comments]
    @app.goals.length.should == 2
    @app.routes.length.should == 1
  end

  it "should allow adding attrs to models" do
    @app.should respond_to :add_attrs
  end
end
