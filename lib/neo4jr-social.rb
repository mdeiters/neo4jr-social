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

include Java

require 'rubygems'

gem 'sinatra'
gem 'json_pure'

require 'sinatra'
require 'json'

find_and_require_neo4jr_simple

require 'neo4jr-social/simple_cost_evaluator'
require 'neo4jr-social/delayed_cost'
require 'neo4jr-social/delayed_cost_evaluator'
require 'neo4jr-social/delayed_cost_accumulator'
require 'neo4jr-social/delayed_cost_comparator'
require 'neo4jr-social/self_documentor'
require 'neo4jr-social/param_helper'
require 'neo4jr-social/format_handler'
require 'neo4jr-social/json_printer'
require 'neo4jr-social/service'