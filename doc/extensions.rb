# the intent of this class is to let people write a goaloc extension,
# which will take in a configuration and return a preconfigured chunk
# of app.  For example:
# route [:site, Blog.new(:comments => :moderated), Wiki.new(:extensions => [:syntax_highlight, :upvotes])]
# might put a blog with moderated contents and a wiki with some
# extensions under /sites for a given app.

class GoalocExtension
  def initialize(config = { }, &block)
    @config = config
    yield(self) if block_given?
    self
  end
end

class Blog < GoalocExtension
  # fill in here the logic for building a blog up.  Should at minimum
  # attach comments.
end
