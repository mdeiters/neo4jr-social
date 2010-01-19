module Neo4jr
  module SelfDocumentor
    def describe(info)
      SelfDocumentor.capture info
    end
        
    def required_param(*args)
      'NOT IMPLEMENTED'
    end
    
    def optional_param(*args)
      'NOT IMPLEMENTED'
    end
    
    def self.capture(text)
      @capture = text
    end
    
    def self.route_added(verb, path, proc)
      if [:get, :post, :put, :delete].include?(verb.downcase.to_sym)
        (@@document ||= []) << {:path => path, :description => (@capture || '').to_s} 
      end
    end
    
    def self.output
      @@document
    end
  end
end