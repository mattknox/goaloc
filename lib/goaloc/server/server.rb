require "rubygems"
require "rack"
class Server
  # this is intended to serve a goaloc app directly, before it has been generated into code for another, lesser framework.
  # this should use rack to actually serve the files, via whatever
  # rack-capable app server the user chooses.

  def initialize(app)
    @app = app
  end

  def call(env)
    respond(handle(env["REQUEST_METHOD"], env["PATH_INFO"]))
  end

  def handle(http_verb, path)
    controller, action = resolve(http_verb, path)
    "#{http_verb}: #{path} resolves to controller: #{} action: #{}"
  end

  def resolve(http_verb, path)
    action = case http_verb
             when "GET" then "index"
             when "POST" then "create"
             when "DELETE" then "destroy"
             when "PUT" then "update"
             end
    ["default_controller", action]
  end

  def respond(content, status_code = 200, headers = { 'Content-Type' => 'text/html' })
    [status_code, headers, content]
  end

  def serve
    Rack::Handler::WEBrick.run self, :Port => 9292
  end
end

Server.new(nil).serve

# this is the output of env.inspect
# {"HTTP_HOST"=>"localhost:9292", "HTTP_ACCEPT"=>"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", "SERVER_NAME"=>"localhost", "REQUEST_PATH"=>"/", "rack.url_scheme"=>"http", "HTTP_KEEP_ALIVE"=>"300", "HTTP_USER_AGENT"=>"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.5; en-US; rv:1.9.0.7) Gecko/2009021906 Firefox/3.0.7", "REMOTE_HOST"=>"localhost", "rack.errors"=>#<IO:0x2ddc0>, "HTTP_ACCEPT_LANGUAGE"=>"en-us,en;q=0.5", "SERVER_PROTOCOL"=>"HTTP/1.1", "rack.version"=>[0, 1], "rack.run_once"=>false, "SERVER_SOFTWARE"=>"WEBrick/1.3.1 (Ruby/1.8.7/2008-08-11)", "REMOTE_ADDR"=>"::1", "PATH_INFO"=>"/foo/2/bar/4/baz", "SCRIPT_NAME"=>"", "HTTP_VERSION"=>"HTTP/1.1", "rack.multithread"=>true, "HTTP_COOKIE"=>"", "rack.multiprocess"=>false, "REQUEST_URI"=>"http://localhost:9292/foo/2/bar/4/baz", "HTTP_ACCEPT_CHARSET"=>"ISO-8859-1,utf-8;q=0.7,*;q=0.7", "SERVER_PORT"=>"9292", "REQUEST_METHOD"=>"GET", "rack.input"=>#<StringIO:0x1976fd4>, "HTTP_ACCEPT_ENCODING"=>"gzip,deflate", "HTTP_CONNECTION"=>"keep-alive", "QUERY_STRING"=>"", "GATEWAY_INTERFACE"=>"CGI/1.1"}
