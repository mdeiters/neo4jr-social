module Neo4jr
  module SelfDocumentor
    def describe(info)
      @@info = info
    end
    
    def parameter(paramter, description)
      
    end
    
    def self.route_added(verb, path, proc)
      (@@document ||= []) << {:path => path, :description => @@info.dup}
    end
    
    def self.output
      @@document
    end
  end
end