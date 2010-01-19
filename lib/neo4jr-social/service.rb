module Neo4jr
  class Service < Sinatra::Base
    helpers ParamHelper
    register SelfDocumentor, FormatHandler
    
    describe "Lists all possible request types with descriptions"
    get '/' do
      render_for_format(SelfDocumentor.output)
    end

    describe "Returns details about the Neo4j database like the location of the database and the number of nodes."
    get '/info' do
      Neo4jr::DB.stats.to_json
    end

    describe "Returns all nodes in the database. Use this method with caution, this could crash your server if you have a database with more then a few thousand nodes."
    get '/nodes' do
      nodes = Neo4jr::DB.execute do |neo|
        nodes = neo.all_nodes.map{|m| m.to_hash }
      end
      nodes.to_json
    end

    describe "Creates a new node in the neo4j database. Any parameters based in the body of the POST will be treated as properties for the node and will be stored in the database."
    post '/nodes' do
      node = Neo4jr::DB.execute do |neo|
        node = neo.create_node(params)
      end
      node.to_hash.to_json
    end

    describe "Returns the properties for the specified node, where :node_id is the numeric id for the node."
    get '/nodes/:node_id' do
      node = Neo4jr::DB.execute do |neo|
        neo.getNodeById(param_node_id).to_hash.to_json
      end
    end

    describe "Updates the properties of the specified node, where :node_id is the numeric id for the node. Any parameters pased in the body of the PUT will be treated as properties for the node. If you add a new parameters (i.e. age=4) which previously were not on the node, neo4jr-social will still add that property to the node."
    put '/nodes/:node_id' do
      node = Neo4jr::DB.execute do |neo|
        node = neo.getNodeById(param_node_id)
        node.update_properties(params)
      end
      node.to_hash.to_json
    end

    describe "Deletes the specified node, where :node_id is the numeric id for the node."
    delete '/nodes/:node_id' do
      Neo4jr::DB.execute do |neo|
        node = neo.getNodeById(param_node_id)
        node.get_relationships.each { |r| r.delete }
        node.delete
      end
    end

    describe "Creates a relations for the specified node, where :node_id is the numeric id for the node. This is how you designate how two nodes are related to each other."
    required_param :to,   'This is the node id of the node you want to make a relationship to. This is a one-way relationship. If you want both nodes to be.'
    required_param :type, "this is the type of the relationship, i.e. 'friends'. This can be any string that is sensible in your domain."
    optional_param "Any other parameters you supply in the body of the POST will be added as properties to the relationship. For example if you were making 'friend' relationships and wanted to add a date since the friendship started you could pass a 'since' parameter in the POST."
    get '/nodes/:node_id/relationships' do
      relationships = Neo4jr::DB.execute do |neo|
        node = neo.getNodeById(param_node_id)
        if param_relationship_type
          relationship_type = RelationshipType.instance(param_relationship_type)
          node.getRelationships(param_relationship_type.to_a).hashify_objects
        else
          node.getRelationships.hashify_objects
        end
      end
      relationships.to_json
    end

    describe "Returns relationships to other nodes for the specified node, where :node_id is the numeric id for the node."
    optional_param :type, "Specify a type if only certain relationships are of interest"
    post '/nodes/:node_id/relationships' do
      relationships = Neo4jr::DB.execute do |neo|
        node = neo.getNodeById(param_node_id)
        to_node = neo.getNodeById(param_to_node_id)
        relationship_type = RelationshipType.instance(param_relationship_type)
        relationship = node.create_relationship_to to_node, relationship_type
        relationship.update_properties(params)
        node.getRelationships(relationship_type.to_a).hashify_objects
      end
      relationships.to_json
    end

    describe "This returns all the ways two nodes are connected to each other and is similar to LinkedIn's degrees of separation. Warning: This is only good for sparse graphs, shortest_paths is better at handling larger connected graphs."
    required_param :to, "the id of the node that your trying to find a path to from the starting node, :node_id"
    required_param :type, "the type of relationships between nodes to follow"
    optional_param :depth, "the maximum degrees of separation to find, the default is 2 degrees. Note: There may be performance impacts if this number is to high."
    optional_param :direction, "hat direction of relationships to follow, the default is 'both'"
    get '/nodes/:node_id/paths' do
      paths = Neo4jr::DB.execute do |neo|
        start_node = neo.getNodeById(param_node_id)
        end_node = neo.getNodeById(param_to_node_id)
        shortest_path = AllSimplePaths.new(start_node, end_node, depth, direction, relationship_types)
        to_hash shortest_path.getPaths
      end
      paths.to_json
    end

    describe "This returns all the shortest paths between two nodes."
    required_param :type, "the type of relationships between nodes to follow"
    optional_param :max_nodes, "The maximum number of nodes to traverse. Defaults to 300"
    optional_param :max_rel, "The maximum number of relationships to traverse. Defaults to 20000"
    optional_param :direction, "hat direction of relationships to follow, the default is 'both'"
    get '/nodes/:node_id/shortest_paths' do
      path = Neo4jr::DB.execute do |neo|
        dijkstra = dijkstra neo
        dijkstra.limitMaxNodesToTraverse(max_nodes)
        dijkstra.limitMaxRelationShipsToTraverse(max_rel)
        to_hash dijkstra.getPaths
      end
      path.to_json
    end

    describe "This returns the first of the shortest path of two nodes that are connected to each other"
    required_param :to, "the id of the node that your trying to find a path to from the starting node, :node_id" 
    required_param :type, "the type of relationships between nodes to follow"
    get '/nodes/:node_id/shortest_path' do
      path = Neo4jr::DB.execute do |neo|
        (p=dijkstra(neo).getPath) and p.map{|n| n.to_hash }
      end
      path.to_json
    end

    describe "This returns node suggestions for the given :node_id. This is similar to facebook friend suggestions where your friend's friends that your not friends with are suggested to you."
    required_param :type, "the type of relationships between nodes to follow" 
    optional_param :leve, "the degree of separation that you want recommendations for, the default is 1 degree away which is similar to facebook's behavior"
    get '/nodes/:node_id/recommendations' do
      suggestions = Neo4jr::DB.execute do |neo|
        relationship = Neo4jr::RelationshipType.incoming(param_relationship_type)
        start_node = neo.getNodeById(param_node_id)
        order = Order::BREADTH_FIRST
        return_when = Return.when do |current_position|
          current_position.depth > param_level
        end
        traverser = start_node.traverse(order, Stop.at(param_level + 1), return_when, relationship)
        traverser.map{|node| node.to_hash }
      end
      suggestions.to_json
    end

    private
    def dijkstra(neo)
      Dijkstra.new(
        0.0,
        neo.getNodeById(param_node_id),
        neo.getNodeById(param_to_node_id),
        Neo4jr::DelayedCostEvaluator.new,
        Neo4jr::DelayedCostAccumulator.new,
        Neo4jr::DelayedCostComparator.new,
        direction,
        relationship_types)
    end

    def to_hash paths
      paths and paths.map{|p| p.map{|n| n.to_hash }}
    end
  end
end