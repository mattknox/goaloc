require File.dirname(__FILE__) + '/../lib/goaloc'

describe App do
  before(:each) do
    @app = App.new
  end

  it "should route things" do
    @app.should respond_to :route
    @app.goals.length.should == 0
  end
end
