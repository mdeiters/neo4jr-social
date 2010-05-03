require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Neo4jr::Service do

  it "should be able to create a node" do
    post '/nodes', 'some_property=a_value&type=person'
    node = response_to_ruby
    node.should have_key('node_id')
    node['type'].should == 'person'
    node['some_property'].should == 'a_value'
  end
  
  it 'should be able to delete a node' do
    post '/nodes', 'type=person'
    node = response_to_ruby
    delete "/nodes/#{node['node_id']}"
    last_response.status.should == 200
    last_response.body.should be_empty
  end
  
  it 'should be able to update a node' do
    post '/nodes', 'some_property=a_value&type=person'
    node = response_to_ruby
    put "/nodes/#{node['node_id']}", 'some_property=changed_value'
    node = response_to_ruby
    node['some_property'].should == 'changed_value'
  end  
  
  it 'should be able to add relationships to nodes' do
    post '/nodes', {:name => 'Philip Seymour Hoffman'}
    actor = response_to_ruby
      
    post '/nodes', {:title => 'The Invention of Lying'}
    movie = response_to_ruby

    post "/nodes/#{actor['node_id']}/relationships", { :to => movie['node_id'], :type => 'acted_in' }
    last_response.status.should == 200
    relationships = response_to_ruby
    relationships.size.should == 1
  end
  
  it 'should return relationships with the to node and type and any other properties added' do
    post '/nodes', {:name => 'Philip Seymour Hoffman'}
    actor = response_to_ruby
      
    post '/nodes', {:title => 'The Invention of Lying'}
    movie = response_to_ruby

    post "/nodes/#{actor['node_id']}/relationships", { :to => movie['node_id'], :type => 'acted_in', :year => 2009 }
    relationship = response_to_ruby.first
    relationship['year'].should == '2009'
    relationship['type'].should == 'acted_in'
    relationship['to'].should == movie['node_id']
  end
    
  describe 'querying paths' do
    let(:hoffman) { post('/nodes', {:name => 'Philip Seymour Hoffman'}) && response_to_ruby }
    let(:fey)     { post( '/nodes', {:name => 'Tina Fey'}) && response_to_ruby}
    let(:hanks)   { post( '/nodes', {:name => 'Tom Hanks'}) && response_to_ruby}
    let(:murphy)  { post( '/nodes', {:name => 'Brittney Murphy'}) && response_to_ruby}
    let(:bale)    { post( '/nodes', {:name => 'Christian Bale'}) && response_to_ruby}
    let(:cruise)  { post( '/nodes', {:name => 'Tom Cruise'}) && response_to_ruby}
    
    before :each do
      @create_mutual_friends = Proc.new do |node1, node2|
        post "/nodes/#{node1['node_id']}/relationships", { :to => node2['node_id'], :type => 'friends' }
        post "/nodes/#{node2['node_id']}/relationships", { :to => node1['node_id'], :type => 'friends' }
      end
      
      @create_mutual_friends.call(hoffman, fey)
      @create_mutual_friends.call(hoffman, murphy)
      @create_mutual_friends.call(murphy, fey)
      @create_mutual_friends.call(murphy, hanks)
      @create_mutual_friends.call(hanks, bale)
    end
    
    describe 'suggestions' do
      it "gets my friend's friends that I'm not friends with as suggestions" do
        get "/nodes/#{hoffman['node_id']}/recommendations?type=friends"
        last_response.status.should == 200
        suggestions = response_to_ruby
        suggestions.size.should == 1
        suggestions.first['name'].should == 'Tom Hanks'
      end

      it "gets my friend's friend's friends that I'm not friends with as suggestions" do
        get "/nodes/#{hoffman['node_id']}/recommendations?type=friends&level=2"
        last_response.status.should == 200
        suggestions = response_to_ruby
        suggestions.size.should == 1
        suggestions.first['name'].should == 'Christian Bale'
      end    
    end
    
    it 'retrieves only shortest path between nodes' do
      @create_mutual_friends.call(fey, cruise)
      @create_mutual_friends.call(hanks, cruise)
      
      get "/nodes/#{hoffman['node_id']}/shortest_path?type=friends&to=#{cruise['node_id']}"
      path_to_cruise = response_to_ruby['path']
      path_to_cruise[0]['name'].should == 'Philip Seymour Hoffman'
      path_to_cruise[1]['type'].should == 'friends'
      path_to_cruise[2]['name'].should == 'Tina Fey'
      path_to_cruise[3]['type'].should == 'friends'
      path_to_cruise[4]['name'].should == 'Tom Cruise'
    end
    
    it "uses the direction of paths to follow when given for shortest path" do
      # only fey to cruise is a friend
      post "/nodes/#{fey['node_id']}/relationships", { :to => cruise['node_id'], :type => 'friends' }
      
      get "/nodes/#{cruise['node_id']}/shortest_path?type=friends&to=#{fey['node_id']}&direction=incoming"
      path_to_fey = response_to_ruby['path']
      path_to_fey[0]['name'].should == 'Tom Cruise'
      path_to_fey[1]['type'].should == 'friends'
      path_to_fey[2]['name'].should == 'Tina Fey'
      
      get "/nodes/#{cruise['node_id']}/shortest_path?type=friends&to=#{fey['node_id']}&direction=outgoing"
      last_response.body.should == 'null'
    end
  end
  
  describe 'getting paths between nodes' do
    let(:actor1) { post('/nodes', {:name => 'Philip Seymour Hoffman'}) && response_to_ruby }
    let(:actor2) { post('/nodes', {:name => 'Tina Fey'}) && response_to_ruby}
    let(:movie)  { post('/nodes', {:title => 'The Invention of Lying'}) && response_to_ruby}
    
    it 'determines all degrees of seperation between nodes like LinkedIn' do
      post "/nodes/#{actor1['node_id']}/relationships", { :to => movie['node_id'], :type => 'acted_in', :year => 2009 }
      post "/nodes/#{actor2['node_id']}/relationships", { :to => movie['node_id'], :type => 'acted_in', :year => 2009 }

      get "/nodes/#{actor1['node_id']}/paths", { :to => actor2['node_id'], :type => 'acted_in'} 
      last_response.status.should == 200
      paths = response_to_ruby
      first_path = paths.first
      first_path[0]['name'].should == 'Philip Seymour Hoffman'
      first_path[2]['title'].should == 'The Invention of Lying'
      first_path[4]['name'].should == 'Tina Fey'
    end
  end
end