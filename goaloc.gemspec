# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{goaloc}
  s.version = "0.4.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["matt knox"]
  s.date = %q{2009-01-26}
  s.default_executable = %q{goaloc}
  s.description = %q{Generate On A Lot of Crack speeds and extends the early sketching phase of RESTFUL MVC app development}
  s.email = %q{matthewknox@gmail.com}
  s.executables = ["goaloc"]
  s.files = ["History.txt", "Manifest.txt", "PostInstall.txt", "VERSION.yml", "bin/bashRake.rb", "bin/goaloc", "lib/goaloc", "lib/goaloc/app.rb", "lib/goaloc/generators", "lib/goaloc/generators/generator.rb", "lib/goaloc/generators/merb", "lib/goaloc/generators/merb/controller.rb.erb", "lib/goaloc/generators/merb/model.rb.erb", "lib/goaloc/generators/merb/router.rb.erb", "lib/goaloc/generators/merb.rb", "lib/goaloc/generators/rails", "lib/goaloc/generators/rails/_form.html.erb", "lib/goaloc/generators/rails/_model.html.erb", "lib/goaloc/generators/rails/_model_small.html.erb", "lib/goaloc/generators/rails/application.html.erb", "lib/goaloc/generators/rails/controller.rb.erb", "lib/goaloc/generators/rails/controller_test.rb.erb", "lib/goaloc/generators/rails/index.html.erb", "lib/goaloc/generators/rails/js-index.html.erb", "lib/goaloc/generators/rails/migration.rb.erb", "lib/goaloc/generators/rails/model.rb.erb", "lib/goaloc/generators/rails/model_test.rb.erb", "lib/goaloc/generators/rails/show.html.erb", "lib/goaloc/generators/rails.rb", "lib/goaloc/generators/resources", "lib/goaloc/generators/resources/bluetrip", "lib/goaloc/generators/resources/bluetrip/css", "lib/goaloc/generators/resources/bluetrip/css/ie.css", "lib/goaloc/generators/resources/bluetrip/css/print.css", "lib/goaloc/generators/resources/bluetrip/css/screen.css", "lib/goaloc/generators/resources/bluetrip/css/style.css", "lib/goaloc/generators/resources/bluetrip/examples", "lib/goaloc/generators/resources/bluetrip/examples/grid.html", "lib/goaloc/generators/resources/bluetrip/examples/index.html", "lib/goaloc/generators/resources/bluetrip/examples/test-small.jpg", "lib/goaloc/generators/resources/bluetrip/img", "lib/goaloc/generators/resources/bluetrip/img/grid.png", "lib/goaloc/generators/resources/bluetrip/img/icons", "lib/goaloc/generators/resources/bluetrip/img/icons/cross.png", "lib/goaloc/generators/resources/bluetrip/img/icons/doc.png", "lib/goaloc/generators/resources/bluetrip/img/icons/email.png", "lib/goaloc/generators/resources/bluetrip/img/icons/external.png", "lib/goaloc/generators/resources/bluetrip/img/icons/feed.png", "lib/goaloc/generators/resources/bluetrip/img/icons/im.png", "lib/goaloc/generators/resources/bluetrip/img/icons/key.png", "lib/goaloc/generators/resources/bluetrip/img/icons/pdf.png", "lib/goaloc/generators/resources/bluetrip/img/icons/tick.png", "lib/goaloc/generators/resources/bluetrip/img/icons/visited.png", "lib/goaloc/generators/resources/bluetrip/img/icons/xls.png", "lib/goaloc/generators/resources/bluetrip/LICENSE", "lib/goaloc/generators/resources/bluetrip/README.rst", "lib/goaloc/generators/resources/jquery-1.2.6.js", "lib/goaloc/generators/resources/jquery-1.2.6.min.js", "lib/goaloc/generators/resources/test_helper.rb", "lib/goaloc/generators/ruby_generator.rb", "lib/goaloc/goal.rb", "lib/goaloc/server", "lib/goaloc/server/server.rb", "lib/goaloc/version.rb", "lib/goaloc.rb", "test/test_app.rb", "test/test_generator.rb", "test/test_goal.rb", "test/test_helper.rb", "test/test_rails_generator.rb", "doc/entity", "doc/route_usage"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/mattknox/goaloc}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{this allows for rapid, console-based generation of merb or rails apps}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
