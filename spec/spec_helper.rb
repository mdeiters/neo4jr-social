$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'neo4jr-social'
require 'spec'
require 'spec/autorun'
require 'rack/test'

Spec::Runner.configure do |config|
  include Rack::Test::Methods

  def app
    Neo4jr::Service
  end
  
  def response_to_ruby
    JSON.parse(last_response.body)
  end
end