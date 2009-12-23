#Ensure service is running at port 4567

require 'rubygems'
require 'httparty'

class LinkedIn
  include HTTParty
  base_uri 'http://localhost:4567'
  format :json
  
  class << self
    def create_person(name)
      post('/nodes', :body => {:name => name})
    end

    def make_mutual_friends(node1, node2)
      post("/nodes/#{node1['node_id']}/relationships", :body => {:to => node2['node_id'], :type => 'friends'})
      post("/nodes/#{node2['node_id']}/relationships", :body => {:to => node1['node_id'], :type => 'friends'})
    end

    def degrees_of_seperation(start_node, destination_node)
      get("/nodes/#{start_node['node_id']}/path", :query => {:to => destination_node['node_id'], :type => 'friends', :depth => 3, :direction => 'outgoing'})
    end
  end
end

johnathan = LinkedIn.create_person('Johnathan')
mark      = LinkedIn.create_person('Mark')
phill     = LinkedIn.create_person('Phill')
mary      = LinkedIn.create_person('Mary')

LinkedIn.make_mutual_friends(johnathan, mark)
LinkedIn.make_mutual_friends(mark, mary)
LinkedIn.make_mutual_friends(mark, phill)
LinkedIn.make_mutual_friends(phill, mary)

LinkedIn.degrees_of_seperation(johnathan, mary).each do |path|
  puts path.map{|node| node['name'] || node['type']}.join(' => ') 
end

# Johnathan => friends => Mark => friends => Phill => friends => Mary
# Johnathan => friends => Mark => friends => Mary