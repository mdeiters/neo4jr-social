# neo4jr-social start -p8988

require 'rubygems'
require 'json'
require 'rest_client'

def create_person(name)
  JSON.parse RestClient.post( "http://localhost:8988/neo4jr-social/nodes", :name => name  )
end

def make_mutual_friends(node1, node2)
  RestClient.post "http://localhost:8988/neo4jr-social/nodes/#{node1['node_id']}/relationships", :to => node2['node_id'], :type => 'friends'
  RestClient.post "http://localhost:8988/neo4jr-social/nodes/#{node2['node_id']}/relationships", :to => node1['node_id'], :type => 'friends'
end

def suggestions_for(start_node)
  JSON.parse RestClient.get("http://localhost:8988/neo4jr-social/nodes/#{start_node['node_id']}/recommendations?type=friends")
end

johnathan = create_person('Johnathan')
mark      = create_person('Mark')
phill     = create_person('Phill')
mary      = create_person('Mary')
luke      = create_person('Luke')

make_mutual_friends(johnathan, mark)
make_mutual_friends(mark, mary)
make_mutual_friends(mark, phill)
make_mutual_friends(phill, mary)
make_mutual_friends(phill, luke)

puts "Johnathan should become friends with #{suggestions_for(johnathan).map{|n| n['name']}.join(', ')}"

# RESULT
# Johnathan should become friends with Mary, Phill