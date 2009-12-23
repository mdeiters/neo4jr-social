# gem 'neo4jr-simple'
require "/Users/mdeiters/development/mymckinsey-neo4j/neo4jr-simple/lib/neo4jr-simple"
require 'lib/neo4jr-social'

run Neo4jr::Service
#LOAD IMDB
# Neo4jr::Configuration.database_path = File.join(File.expand_path(File.dirname(__FILE__)), '..', 'neo4jr-simple', 'spec','test-imdb-database' )