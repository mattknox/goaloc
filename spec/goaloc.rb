require File.dirname(__FILE__) + '/../lib/goaloc'

describe Goaloc do
  before(:each) do
    @app = App.new
  end

  it "should do stuff" do
    @app.should respond_to :route
  end
end