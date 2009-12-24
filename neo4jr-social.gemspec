# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{neo4jr-social}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Matthew Deiters"]
  s.date = %q{2009-12-23}
  s.default_executable = %q{start-neo4jr-social}
  s.description = %q{A self-containted lightweight REST interface to Neo4j using JRuby }
  s.email = %q{matthew_deiters@mckinsey.com}
  s.executables = ["start-neo4jr-social"]
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc",
     "TODO"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "TODO",
     "VERSION",
     "bin/start-neo4jr-social",
     "config.ru",
     "examples/facebook.rb",
     "examples/linkedin.rb",
     "jetty-runtime/etc/jetty.xml",
     "jetty-runtime/etc/webdefault.xml",
     "jetty-runtime/lib/jetty-6.1.3.jar",
     "jetty-runtime/lib/jetty-util-6.1.3.jar",
     "jetty-runtime/lib/jsp-2.1/ant-1.6.5.jar",
     "jetty-runtime/lib/jsp-2.1/core-3.1.1.jar",
     "jetty-runtime/lib/jsp-2.1/jsp-2.1.jar",
     "jetty-runtime/lib/jsp-2.1/jsp-api-2.1.jar",
     "jetty-runtime/lib/servlet-api-2.5-6.1.3.jar",
     "jetty-runtime/start.jar",
     "jetty-runtime/webapps/neo4jr-social.war",
     "lib/neo4jr-social.rb",
     "lib/neo4jr-social/service.rb",
     "lib/neo4jr-social/version.rb",
     "spec/service_spec.rb",
     "spec/spec.opts",
     "spec/spec_helper.rb",
     "tmp/war/WEB-INF/lib/jruby-core-1.4.0.jar",
     "tmp/war/WEB-INF/lib/jruby-rack-0.9.5.jar",
     "tmp/war/WEB-INF/lib/jruby-stdlib-1.4.0.jar",
     "tmp/war/WEB-INF/lib/neo4jr-social.rb",
     "tmp/war/WEB-INF/lib/neo4jr-social/service.rb",
     "tmp/war/WEB-INF/lib/neo4jr-social/version.rb",
     "tmp/war/WEB-INF/web.xml"
  ]
  s.homepage = %q{http://github.com/mdeiters/neo4jr-social}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{A self-containted and lightweight REST interface to Neo4j using JRuby.}
  s.test_files = [
    "spec/service_spec.rb",
     "spec/spec_helper.rb",
     "examples/facebook.rb",
     "examples/linkedin.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rspec>, [">= 1.2.9"])
      s.add_development_dependency(%q<httparty>, [">= 0"])
      s.add_runtime_dependency(%q<neo4jr-simple>, [">= 0"])
      s.add_runtime_dependency(%q<sinatra>, [">= 0"])
      s.add_runtime_dependency(%q<json_pure>, [">= 0"])
    else
      s.add_dependency(%q<rspec>, [">= 1.2.9"])
      s.add_dependency(%q<httparty>, [">= 0"])
      s.add_dependency(%q<neo4jr-simple>, [">= 0"])
      s.add_dependency(%q<sinatra>, [">= 0"])
      s.add_dependency(%q<json_pure>, [">= 0"])
    end
  else
    s.add_dependency(%q<rspec>, [">= 1.2.9"])
    s.add_dependency(%q<httparty>, [">= 0"])
    s.add_dependency(%q<neo4jr-simple>, [">= 0"])
    s.add_dependency(%q<sinatra>, [">= 0"])
    s.add_dependency(%q<json_pure>, [">= 0"])
  end
end

