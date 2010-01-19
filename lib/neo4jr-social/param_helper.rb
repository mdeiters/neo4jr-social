module Neo4jr
  module ParamHelper

    def param_node_id
      params.delete('node_id')
    end
    
    def param_relationship_type
      @param_relationship_type ||= params.delete('type')
    end
    
    def param_to_node_id
      params.delete('to')
    end

    def param_depth
      (params.delete('depth') || 2).to_i
    end
    
    def param_level 
      @param_level ||= (params.delete('level') || 1).to_i
    end

    def param_direction
      Neo4jr::Direction.from_string(params.delete('direction') || 'both')
    end

    def relationship_types
      (param_relationship_type.nil? ? [] : [param_relationship_type].flatten.map {|name| DynamicRelationshipType.with_name(name)}).to_java(DynamicRelationshipType)
    end
  end
end