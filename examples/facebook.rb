# neo4jr-social start -p8988

require 'rubygems'
require 'httparty'

class Facebook
  include HTTParty
  base_uri 'http://localhost:8988/neo4jr-social'
  format :json
  
  class << self
    def create_person(name)
      post('/nodes', :body => {:name => name})
    end

    def make_mutual_friends(node1, node2)
      post("/nodes/#{node1['node_id']}/relationships", :body => {:to => node2['node_id'], :type => 'friends'})
      post("/nodes/#{node2['node_id']}/relationships", :body => {:to => node1['node_id'], :type => 'friends'})
    end

    def suggestions_for(start_node)
      get("/nodes/#{start_node['node_id']}/recommendations?type=friends")
    end
  end
end

johnathan = Facebook.create_person('Johnathan')
mark      = Facebook.create_person('Mark')
phill     = Facebook.create_person('Phill')
mary      = Facebook.create_person('Mary')
luke      = Facebook.create_person('Luke')

Facebook.make_mutual_friends(johnathan, mark)
Facebook.make_mutual_friends(mark, mary)
Facebook.make_mutual_friends(mark, phill)
Facebook.make_mutual_friends(phill, mary)
Facebook.make_mutual_friends(phill, luke)

puts "Johnathan should become friends with #{Facebook.suggestions_for(johnathan).map{|n| n['name']}.join(', ')}"
#=> Johnathan should become friends with Mary, Phill