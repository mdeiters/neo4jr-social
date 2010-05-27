# Warbler web application assembly configuration file
Warbler::Config.new do |config|
  config.dirs = %w(lib)
  config.includes = FileList["config.ru"]

  config.gems << Gem::Dependency.new("sinatra", ">= 1.0")
  config.gems << Gem::Dependency.new("json-jruby", ">= 1.4.1")
  config.gems << Gem::Dependency.new("neo4jr-simple", ">= 0.2.1")
  
  config.gem_dependencies = true
  config.webxml.booter = :rack

  # Control the pool of runtimes. Leaving unspecified means
  # the pool will grow as needed to service requests. It is recommended
  # that you fix these values when running a production server!
  # config.webxml.jruby.min.runtimes = 2
  # config.webxml.jruby.max.runtimes = 4
end
