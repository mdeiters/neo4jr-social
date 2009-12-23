$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)))

include Java

require 'rubygems'
gem 'sinatra'
gem 'json_pure'

require 'sinatra'
require 'json'
require 'neo4jr-social/service'

# http://localhost:8988/neo4jr-social/nodes
