$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

def find_and_require_neo4jr_simple
  neo4jr_simple_root = java.lang.System.getProperty('neo4jr.simple') || ENV['neo4jr_simple']
  if neo4jr_simple_root
    $LOAD_PATH.unshift(File.join(neo4jr_simple_root, 'lib'))
  else
    gem 'neo4jr-simple'
  end  
  require 'neo4jr-simple'
end

def find_and_require_user_defined_code
  extensions_path = java.lang.System.getProperty('neo4jr.extensions') || ENV['neo4jr_extensions'] || "~/.neo4jr-social"
  extensions_path = File.expand_path(extensions_path)
  if File.exists?(extensions_path)
    Dir.open extensions_path do |dir|
      dir.entries.each do |file|
        if file.split('.').size > 1 && file.split('.').last == 'rb'
          extension = File.join(File.expand_path(extensions_path), file) 
          require(extension) && puts("Loaded Extension: #{extension}")
        end
      end
    end
  else
    puts "No Extensions Found: #{extensions_path}"
  end
end

include Java

require 'rubygems'

gem 'sinatra'
gem 'json-jruby'

require 'sinatra'
require 'json'

find_and_require_neo4jr_simple

require 'neo4jr-social/self_documentor'
require 'neo4jr-social/param_helper'
require 'neo4jr-social/format_handler'
require 'neo4jr-social/json_printer'
require 'neo4jr-social/service'

find_and_require_user_defined_code