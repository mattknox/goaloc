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



################################################################################
# this is the original merb pastie, from which I will loot code to make goaloc
# serve itself.

# #!/usr/local/bin/ruby
# require 'rubygems'
# require 'mongrel'

# # Add the request handler directory to the load path.
# # Files in the 'app/controllers' dir will be mapped against the first segment
# # of a URL
# $LOAD_PATH.unshift( File.join( File.dirname( __FILE__ ) , 'app/controllers' ) )

# PORT = 4000

#  # If true, controller source files are 'load'ed rather than 'require'd
# # so you can tweak code and reload a page.
# ALLOW_RELOADING = true 

# class String
#   def import
#     ALLOW_RELOADING ? load(  self  + '.rb' ) : require(  self )
#   end

#   def controller_class_name
#     self.capitalize
#   end
# end

# class MerberHandler < Mongrel::HttpHandler

#   def instantiate_controller(controller_name)
#     controller_name.import
#     begin
#       return Object.const_get( controller_name.controller_class_name ).new
#     rescue Exception
#       # If life is sad, then print the error and re-raise the exception:
#       warn "Error getting instance of '#{controller_name.controller_class_name}': #{$!}"
#       raise $!
#     end
#   end

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

 
