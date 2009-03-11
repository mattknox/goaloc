class Server
  # this is intended to serve a goaloc app directly, before it has been generated into code for another, lesser framework.
  # this should use rack to actually serve the files, probably via mongrel or something.

  @app = proc do |env|
    [200, { 'Content-Type' => 'text/html' }, "no content yet"]
  end
  Rack::Handler::WEBrick.run app, :Port => 9292
end
