# neo4jr-social start -p8988

require 'rubygems'
require 'json'
require 'rest_client'

def create_person(name)
  response = RestClient.post "http://localhost:8988/neo4jr-social/nodes", :name => name  
  JSON.parse(response)
end

def make_mutual_friends(node1, node2)
  RestClient.post "http://localhost:8988/neo4jr-social/nodes/#{node1['node_id']}/relationships", :to => node2['node_id'], :type => 'friends'
  RestClient.post "http://localhost:8988/neo4jr-social/nodes/#{node2['node_id']}/relationships", :to => node1['node_id'], :type => 'friends'
end

def degrees_of_seperation(start_node, destination_node)
  url = "http://localhost:8988/neo4jr-social/nodes/#{start_node['node_id']}/paths?to=#{destination_node['node_id']}&type=friends&depth=3&direction=outgoing"
  response = RestClient.get(url)
  JSON.parse(response)
end

johnathan = create_person('Johnathan')
mark      = create_person('Mark')
phill     = create_person('Phill')
mary      = create_person('Mary')

make_mutual_friends(johnathan, mark)
make_mutual_friends(mark, mary)
make_mutual_friends(mark, phill)
make_mutual_friends(phill, mary)

degrees_of_seperation(johnathan, mary).each do |path|
  puts path.map{|node| node['name'] || node['type']}.join(' => ') 
end

# RESULT
# Johnathan => friends => Mark => friends => Phill => friends => Mary
# Johnathan => friends => Mark => friends => Mary