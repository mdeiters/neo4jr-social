java_import org.neo4j.graphalgo.shortestpath.Dijkstra
java_import org.neo4j.graphalgo.shortestpath.std.IntegerEvaluator
java_import org.neo4j.graphalgo.shortestpath.std.DoubleAdder
java_import org.neo4j.graphalgo.shortestpath.std.DoubleComparator
java_import org.neo4j.api.core.DynamicRelationshipType

module Neo4jr
  class Service < Sinatra::Base

    get '/' do
      'hello world, will be replaced by documenting service'
    end

    get '/info' do
      Neo4jr::DB.stats.to_json
    end

    get '/nodes' do
      nodes = Neo4jr::DB.execute do |neo|
        nodes = neo.all_nodes.map{|m| m.to_hash }
      end
      nodes.to_json
    end

    post '/nodes' do
      node = Neo4jr::DB.execute do |neo|
        node = neo.create_node(params)
      end
      node.to_hash.to_json
    end

    get '/nodes/:node_id' do
      node = Neo4jr::DB.execute do |neo|
        neo.getNodeById(params.delete('node_id')).to_hash.to_json
      end
    end

    put '/nodes/:node_id' do
      node = Neo4jr::DB.execute do |neo|
        node = neo.getNodeById(params.delete('node_id'))
        node.update_properties(params)
      end
      node.to_hash.to_json
    end

    delete '/nodes/:node_id' do
      Neo4jr::DB.execute do |neo|
        node = neo.getNodeById(params['node_id'])
        node.getRelationships.each {|r| r.delete}
        node.delete
      end
    end

    get '/nodes/:node_id/relationships' do
      relationships = Neo4jr::DB.execute do |neo|
        node = neo.getNodeById(params.delete('node_id'))
        if relationship_type = params.delete('type')
          relationship_type = RelationshipType.instance(relationship_type)
          node.getRelationships(relationship_type.to_a).hashify_objects
        else
          node.getRelationships.hashify_objects
        end
      end
      relationships.to_json
    end

    post '/nodes/:node_id/relationships' do
      relationships = Neo4jr::DB.execute do |neo|
        node = neo.getNodeById(params.delete('node_id'))
        to_node = neo.getNodeById(params.delete('to'))
        relationship_type = RelationshipType.instance(params.delete('type'))
        relationship = node.create_relationship_to to_node, relationship_type
        relationship.update_properties(params)
        node.getRelationships(relationship_type.to_a).hashify_objects
      end
      relationships.to_json
    end

    get '/nodes/:node_id/paths' do
      paths = Neo4jr::DB.execute do |neo|
        start_node = neo.getNodeById(params.delete('node_id'))
        end_node = neo.getNodeById(params.delete('to'))
        shortest_path = AllSimplePaths.new(start_node, end_node, depth, direction, relationship_types)
        to_hash shortest_path.getPaths
      end
      paths.to_json
    end

    get '/nodes/:node_id/dijkstra_paths' do
      path = Neo4jr::DB.execute do |neo|
        dijkstra = dijkstra neo
        dijkstra.limitMaxNodesToTraverse(max_nodes)
        dijkstra.limitMaxRelationShipsToTraverse(max_rel)
        to_hash dijkstra.getPaths
      end
      path.to_json
    end

    get '/nodes/:node_id/shortest_path' do
      path = Neo4jr::DB.execute do |neo|
        (p=dijkstra(neo).getPath) and p.map{|n| n.to_hash }
      end
      path.to_json
    end

    get '/nodes/:node_id/recommendations' do
      suggestions = Neo4jr::DB.execute do |neo|
        relationship = Neo4jr::RelationshipType.incoming(params.delete('type'))
        start_node = neo.getNodeById(params.delete('node_id'))
        level = (params.delete('level') || 1).to_i
        order = Order::BREADTH_FIRST
        return_when = Return.when do |current_position|
          current_position.depth > level
        end
        traverser = start_node.traverse(order, Stop.at(level + 1), return_when, relationship)
        traverser.map{|node| node.to_hash }
      end
      suggestions.to_json
    end

    private
    def dijkstra neo
      Dijkstra.new(
              0.0,
              neo.getNodeById(params.delete('node_id')),
              neo.getNodeById(params.delete('to')),
              Neo4jr::SimpleEvaluator.new,
              DoubleAdder.new,
              DoubleComparator.new,
              direction,
              relationship_types)
    end

    def max_nodes
      (params.delete('max_nodes') || 300).to_i
    end

    def max_rel
      (params.delete('max_rel') || 20000).to_i
    end

    def depth
      (params.delete('depth') || n).to_i
    end

    def direction
      Neo4jr::Direction.from_string(params.delete('direction') || 'both')
    end

    def relationship_types
      names = params.delete('type')
      (names.nil? ? [] : [names].flatten.map {|name| DynamicRelationshipType.with_name(name)}).to_java(DynamicRelationshipType)
    end

    def to_hash paths
      paths and paths.map{|p| p.map{|n| n.to_hash }}
    end
  end
end