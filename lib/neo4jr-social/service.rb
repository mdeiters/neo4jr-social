module Neo4jr
  class Service < Sinatra::Base
    register SelfDocumentor
    # register FormatHandler
    # register ParamHelper
    
    mime :json, 'application/json'
    set :default_charset, 'utf-8'
    set :assume_xhr_is_js, true
          
    before do
      if request.env['HTTP_ACCEPT'] && request.env['HTTP_ACCEPT'].include?('text/html')
        format :html
      else
        format :json
      end
      charset options.default_charset
    end

    describe "Lists all possible request types with descriptions"
    get '/' do
      # format(default_for_this_request = :html)
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
        neo.getNodeById(params.delete('node_id')).to_hash.to_json
      end
    end

    describe "Updates the properties of the specified node, where :node_id is the numeric id for the node. Any parameters pased in the body of the PUT will be treated as properties for the node. If you add a new parameters (i.e. age=4) which previously were not on the node, neo4jr-social will still add that property to the node."
    put '/nodes/:node_id' do
      node = Neo4jr::DB.execute do |neo|
        node = neo.getNodeById(params.delete('node_id'))
        node.update_properties(params)
      end
      node.to_hash.to_json
    end

    describe "Deletes the specified node, where :node_id is the numeric id for the node."
    delete '/nodes/:node_id' do
      Neo4jr::DB.execute do |neo|
        node = neo.getNodeById(params['node_id'])
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

    describe "Returns relationships to other nodes for the specified node, where :node_id is the numeric id for the node."
    optional_param :type, "Specify a type if only certain relationships are of interest"
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

    describe "This returns all the ways two nodes are connected to each other and is similar to LinkedIn's degrees of separation."
    required_param :to, "the id of the node that your trying to find a path to from the starting node, :node_id"
    required_param :type, "the type of relationships between nodes to follow"
    optional_param :depth, "the maximum degrees of separation to find, the default is 2 degrees. Note: There may be performance impacts if this number is to high."
    optional_param :direction, "hat direction of relationships to follow, the default is 'both'"
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

    describe "This returns the shortest path of two nodes that are connected to each other"
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
    def render_for_format(data)
      # return JsonPrinter.render(data)
      case format
        when :json : return JsonPrinter.render(data)
        when :html : return JsonPrinter.render_html(data)
        else
           fail("#{format} is not a supported MIME type")
      end
    end
    
    def dijkstra(neo)
      Dijkstra.new(
        0.0,
        neo.getNodeById(params.delete('node_id')),
        neo.getNodeById(params.delete('to')),
        Neo4jr::DelayedCostEvaluator.new,
        Neo4jr::DelayedCostAccumulator.new,
        Neo4jr::DelayedCostComparator.new,
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
    
    def format(val=nil)
      unless val.nil?
       mime_type = media_type(val)
       fail "Unknown media type #{val}\nTry registering the extension with a mime type" if mime_type.nil?

       @format = val.to_sym
       response['Content-Type'].sub!(/^[^;]+/, mime_type)
      end

      @format
    end

    def charset(val=nil)
      fail "Content-Type must be set in order to specify a charset" if response['Content-Type'].nil?

      if response['Content-Type'] =~ /charset=[^;]+/
        response['Content-Type'].sub!(/charset=[^;]+/, (val == '' && '') || "charset=#{val}")
      else
        response['Content-Type'] += ";charset=#{val}"
      end unless val.nil?

      response['Content-Type'][/charset=([^;]+)/, 1]
    end

  end
end