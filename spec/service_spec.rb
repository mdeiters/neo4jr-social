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
  
  it 'determines degrees of seperation between nodes like LinkedIn' do
    post '/nodes', {:name => 'Philip Seymour Hoffman'}
    actor1 = response_to_ruby
  
    post '/nodes', {:title => 'The Invention of Lying'}
    movie = response_to_ruby
  
    post '/nodes', {:name => 'Tina Fey'}
    actor2 = response_to_ruby

    post "/nodes/#{actor1['node_id']}/relationships", { :to => movie['node_id'], :type => 'acted_in', :year => 2009 }
    post "/nodes/#{actor2['node_id']}/relationships", { :to => movie['node_id'], :type => 'acted_in', :year => 2009 }


    get "/nodes/#{actor1['node_id']}/path", { :to => actor2['node_id'], :type => 'acted_in'} 
    last_response.status.should == 200
    paths = response_to_ruby
    first_path = paths.first
    first_path[0]['name'].should == 'Philip Seymour Hoffman'
    first_path[2]['title'].should == 'The Invention of Lying'
    first_path[4]['name'].should == 'Tina Fey'
  end
  
  it 'retrieves related nodes that a node is not directrly related to like Facebook friend suggestions' do
    post '/nodes', {:name => 'Philip Seymour Hoffman'}
    hoffman = response_to_ruby
  
    post '/nodes', {:name => 'Tina Fey'}
    fey = response_to_ruby
    
    post '/nodes', {:name => 'Tom Hanks'}
    hanks = response_to_ruby

    post '/nodes', {:name => 'Brittney Murphy'}
    murphy = response_to_ruby
    
    # hoffman => [fey, murphy]
    # fey => [hoffman, murphy, hanks]
    post "/nodes/#{hoffman['node_id']}/relationships", { :to => fey['node_id'], :type => 'friends' }
    post "/nodes/#{fey['node_id']}/relationships",     { :to => hoffman['node_id'], :type => 'friends' }
    post "/nodes/#{fey['node_id']}/relationships",     { :to => hanks['node_id'], :type => 'friends' }
    post "/nodes/#{hanks['node_id']}/relationships",   { :to => fey['node_id'], :type => 'friends' }
    post "/nodes/#{hoffman['node_id']}/relationships", { :to => murphy['node_id'], :type => 'friends' }
    post "/nodes/#{murphy['node_id']}/relationships",  { :to => hoffman['node_id'], :type => 'friends' }
    post "/nodes/#{murphy['node_id']}/relationships",  { :to => fey['node_id'], :type => 'friends' }
    post "/nodes/#{fey['node_id']}/relationships",     { :to => hoffman['node_id'], :type => 'friends' }

    
    get "/nodes/#{hoffman['node_id']}/recommendations?type=friends"
    last_response.status.should == 200
    suggestions = response_to_ruby
    suggestions.size.should == 1
    suggestions.first['name'].should == 'Tom Hanks'
  end

end