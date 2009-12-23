require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "neo4jr-social"
    gem.summary = %Q{TODO: one-line summary of your gem}
    gem.description = %Q{TODO: longer description of your gem}
    gem.email = "matthew_deiters@mckinsey.com"
    gem.homepage = "http://github.com/mdeiters/neo4jr-social"
    gem.authors = ["Matthew Deiters"]
    gem.add_development_dependency "rspec", ">= 1.2.9"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "neo4jr-social #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

task :warify do
  commands = ['rm -rf tmp']
  commands << 'warble'
  commands << 'rm jetty-runtime/webapps/neo4jr-social.war'
  commands << 'mv neo4jr-social.war jetty-runtime/webapps/neo4jr-social.war'
  commands.each do |command|
    STDERR.puts("Executing: #{command}")
    `#{command}`
  end
end

namespace :development do
  task :start => :warify do
    `bin/neo4jr-social start`
  end
end