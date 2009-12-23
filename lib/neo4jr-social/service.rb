module Neo4jr
  class Service < Sinatra::Base
            
    get '/info' do
      Neo4jr::DB.to_s
    end
    
    get '/nodes' do
      nodes = []
      Neo4jr::DB.execute do |neo|
        nodes = neo.all_nodes.map{|m| m.to_hash }
      end
      nodes.to_json
    end
  
    post '/nodes' do
      node = nil
      Neo4jr::DB.execute do |neo|
        node = neo.createNode
        params.each_pair do |key, value|
          node[key] = value
        end
        node
      end
      node.to_hash.to_json
    end
    
    put '/nodes/:node_id' do
      node = nil
      Neo4jr::DB.execute do |neo|
        node = neo.getNodeById(params['node_id'].to_f)
        params.each_pair do |key, value|
          node[key] = value
        end
      end
      node.to_hash.to_json
    end
    
    delete '/nodes/:node_id' do
      Neo4jr::DB.execute do |neo|
        node = neo.getNodeById(params['node_id'].to_f)
        node.delete
      end
    end
    
    get '/nodes/:node_id/relationships' do
      relationships = nil
      Neo4jr::DB.execute do |neo|
        node = neo.getNodeById(params.delete('node_id').to_f)
        to_node = neo.getNodeById(params.delete('to').to_f)
        relationship_type = RelationshipType.instance(params.delete('type'))
        relationship = node.create_relationship_to to_node, relationship_type
        params.each_pair do |key, value|
          relationship[key] = value
        end
        relationships = node.getRelationships([relationship_type].to_java(org.neo4j.api.core.RelationshipType)).map do |relationship| 
          relationship.to_hash
        end
      end
      relationships.to_json
    end
    
    post '/nodes/:node_id/relationships' do
      relationships = nil
      Neo4jr::DB.execute do |neo|
        node = neo.getNodeById(params.delete('node_id').to_f)
        to_node = neo.getNodeById(params.delete('to').to_f)
        relationship_type = RelationshipType.instance(params.delete('type'))
        relationship = node.create_relationship_to to_node, relationship_type
        params.each_pair do |key, value|
          relationship[key] = value
        end
        relationships = node.getRelationships([relationship_type].to_java(org.neo4j.api.core.RelationshipType)).map do |relationship| 
          relationship.to_hash
        end
      end
      relationships.to_json
    end

    #optional direction & depth
    get '/nodes/:node_id/path' do
      paths = nil
      Neo4jr::DB.execute do |neo|
        worked_with_relationship = [Neo4jr::RelationshipType.instance(params.delete('type'))].to_java(org.neo4j.api.core.RelationshipType)
        start_node = neo.getNodeById(params.delete('node_id').to_f)
        end_node = neo.getNodeById(params.delete('to').to_f)
        depth = params.delete('depth') || 2
        direction = Neo4jr::Direction.from_string(params.delete('direction') || 'both')
        shortest_path = AllSimplePaths.new(start_node, end_node, depth.to_i, direction, worked_with_relationship)
        paths = shortest_path.getPaths
        paths = paths.map{|p| p.map{|n| n.to_hash }}
      end
      paths.to_json
    end
    
    get '/nodes/:node_id/recommendations' do
      suggestions = nil
      Neo4jr::DB.execute do |neo|
        relationship = Neo4jr::RelationshipType.incoming(params.delete('type'))
        start_node   = neo.getNodeById(params.delete('node_id').to_f)
        order        = Order::BREADTH_FIRST
        return_when  = Return.when do |current_position|
          current_position.depth > 1
        end
        traverser = start_node.traverse(order, Stop.at(2), return_when, relationship)
        suggestions = traverser.map{|node| node.to_hash }
      end
      suggestions.to_json
    end
  end
end