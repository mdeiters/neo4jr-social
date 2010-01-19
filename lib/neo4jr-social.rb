$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

def find_and_load_neo4jr_simple
  java_import java.lang.System
  neo4jr_simple_root = System.getProperty('neo4jr.simple') || ENV['neo4jr_simple']
  if neo4jr_simple_root
    $LOAD_PATH.unshift(File.join(neo4jr_simple_root, 'lib'))
  else
    gem 'neo4jr-simple'
  end  
end

include Java
find_and_load_neo4jr_simple

gem 'sinatra'
gem 'json_pure'  

require 'sinatra'
require 'json'
require 'neo4jr-simple'

require 'neo4jr-social/simple_cost_evaluator'
require 'neo4jr-social/delayed_cost'
require 'neo4jr-social/delayed_cost_evaluator'
require 'neo4jr-social/delayed_cost_accumulator'
require 'neo4jr-social/delayed_cost_comparator'
require 'neo4jr-social/self_documentor'
require 'neo4jr-social/json_printer'
# require 'neo4jr-social/respond_to'
require 'neo4jr-social/service'
