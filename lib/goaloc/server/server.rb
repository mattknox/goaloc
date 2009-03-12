require "rack"
class Server
  # this is intended to serve a goaloc app directly, before it has been generated into code for another, lesser framework.
  # this should use rack to actually serve the files, probably via mongrel or something.

  def call(env)
    puts env.inspect
    respond(env["REQUEST_METHOD"] + ": " + env["PATH_INFO"])
  end

  def respond(content, status_code = 200, headers = { 'Content-Type' => 'text/html' })
    [status_code, headers, content]
  end
  
  def serve
    Rack::Handler::WEBrick.run self, :Port => 9292
  end
end


# this is the output of env.inspect
# {"HTTP_HOST"=>"localhost:9292", "HTTP_ACCEPT"=>"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", "SERVER_NAME"=>"localhost", "REQUEST_PATH"=>"/", "rack.url_scheme"=>"http", "HTTP_KEEP_ALIVE"=>"300", "HTTP_USER_AGENT"=>"Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.5; en-US; rv:1.9.0.7) Gecko/2009021906 Firefox/3.0.7", "REMOTE_HOST"=>"localhost", "rack.errors"=>#<IO:0x2ddc0>, "HTTP_ACCEPT_LANGUAGE"=>"en-us,en;q=0.5", "SERVER_PROTOCOL"=>"HTTP/1.1", "rack.version"=>[0, 1], "rack.run_once"=>false, "SERVER_SOFTWARE"=>"WEBrick/1.3.1 (Ruby/1.8.7/2008-08-11)", "REMOTE_ADDR"=>"::1", "PATH_INFO"=>"/foo/2/bar/4/baz", "SCRIPT_NAME"=>"", "HTTP_VERSION"=>"HTTP/1.1", "rack.multithread"=>true, "HTTP_COOKIE"=>"_post_session=BAh7CzoQc2NvcmVrZWVwZXIiEHNjb3Jla2VlcGVyOhBoYXNfYWRkcmVzcyIJdHJ1ZToMY3NyZl9pZCIlNTk1Y2E1NjYwZTZiNWZiYzczYzMzMWE4NDliYWFmY2I6DHVzZXJfaWRpBiIKZmxhc2hJQzonQWN0aW9uQ29udHJvbGxlcjo6Rmxhc2g6OkZsYXNoSGFzaHsGOgtub3RpY2UiJVRhcmdldCB3YXMgc3VjY2Vzc2Z1bGx5IGNyZWF0ZWQuBjoKQHVzZWR7BjsKVDoRc3BlY2lhbHR5X2lkaQ0%3D--6358f81f2e2a534b426af083530545f69fe3f8d2; _untitled-985439_session=BAh7ByIKZmxhc2hJQzonQWN0aW9uQ29udHJvbGxlcjo6Rmxhc2g6OkZsYXNo%0ASGFzaHsABjoKQHVzZWR7ADoMY3NyZl9pZCIlNDBiMzdmOGFhMjM1ZDUyNDk2%0AMWVlOWUwMmZiZmI0ZDM%3D--d4890e6e83abf3cc4e43033cf2dd951d4793e7c2; _goaloc_generated_app_session=BAh7CDoQX2NzcmZfdG9rZW4iMVZvdzBDVTUvWkg1TWhMOGJHYmxhOCtrVDlUbWFrUEwrZzU5cDN1OXAxZ1U9Og9zZXNzaW9uX2lkIiVjM2Y2YjBiZTE2NGM5ODU5Y2M0NjEwMjlhOWYzNGFlYiIKZmxhc2hJQzonQWN0aW9uQ29udHJvbGxlcjo6Rmxhc2g6OkZsYXNoSGFzaHsGOgtub3RpY2UiJkNvbW1lbnQgd2FzIHN1Y2Nlc3NmdWxseSBjcmVhdGVkLgY6CkB1c2VkewY7CFQ%3D--27820f97b3be0252804cfb00b08e02e82e6a4bb6", "rack.multiprocess"=>false, "REQUEST_URI"=>"http://localhost:9292/foo/2/bar/4/baz", "HTTP_ACCEPT_CHARSET"=>"ISO-8859-1,utf-8;q=0.7,*;q=0.7", "SERVER_PORT"=>"9292", "REQUEST_METHOD"=>"GET", "rack.input"=>#<StringIO:0x1976fd4>, "HTTP_ACCEPT_ENCODING"=>"gzip,deflate", "HTTP_CONNECTION"=>"keep-alive", "QUERY_STRING"=>"", "GATEWAY_INTERFACE"=>"CGI/1.1"}
# this is the line of output from rack
# localhost - - [12/Mar/2009:13:46:54 EDT] "GET /foo/2/bar/4/baz HTTP/1.1" 200 21


################################################################################
# this is a hacked up version of the original merb pastie, from which I will
# loot code to make goaloc serve itself.

#   # Grab the request URL and break it up to get the parts that map to the 
#   # code request.  There's a simple assumption that the first part defines a
#   # class holding the desired  code.
#   def handle(request)
#     path = request.params["PATH_INFO"]
#     puts request.inspect
#     puts '='*50
#     # Might want to consider returning a default object if we have a bare URL.
#     return [nil, nil, nil ] if path =~ /^\/$/
#     c, m, args = path.to_s.gsub( /^\//, '' ).split( '/' , 3)
#     args = args.to_s.strip.empty? ? nil : args.split( '/' )
#     # STDERR.puts( "handler_details  returning #{h}, #{m}, #{args.inspect} ")
#     # Return an array with our object instance, the method name, and any args.
#     [ instantiate_controller(c), m, args ]
#   end

#   def process(request, response)
#     response.start(200) do |head,out|
#       head["Content-Type"] = "text/html"
#       begin
#         # Looks at the URL and breaks it up into 
#         # chunks that  map to a class, a method call,
#         # and arguments.
#         # Basically, 
#         #   /foo/bar/baz/baz
#         # ends up becoming
#         #   Foo.new.bar( baz, baz )
#         controller, method, args = handle(request)

#         if controller
#           # No allowance for default methods.  
#           # Worth considering, maybe default to 'index' or 'to_s' 
#           out << (  args ?  controller.send( method, *args ) : 
#                             controller.send( method ) )
#         else
#           out << "Error: no merb controller found for this url."
#         end
#       rescue Exception
#         out << "Error! #{$!}"
#       end
#     end
#   end

# end

# h = Mongrel::HttpServer.new("0.0.0.0", PORT)
# h.register("/", MerberHandler.new)
# h.register("/", Mongrel::DirHandler.new("assets"))
# h.run.join


# --merb.rb---
# require 'erb'

# class Merb
#   # Define a class variable to track the default location of the template
#   # files.
#   @@template_dir = File.expand_path( ( File.dirname( __FILE__ ) + "/../views/merb" ) )


#   def hello(*names)
#     # Assign the parameter to an instance variable
#     @name = names.join(', ')
#     template = ERB.new( IO.read( @@template_dir + '/hello.rhtml' ) ) 
#     template.result( binding )
#   end
# end


# --hello.rhtml--
 
 
  
 
 
# Hello, <%= @name %>!

 
