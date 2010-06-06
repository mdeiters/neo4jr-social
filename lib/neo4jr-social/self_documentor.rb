module Neo4jr
  module SelfDocumentor
    def describe(info)
      SelfDocumentor.capture info
    end
    
    def required_param(*args)
      SelfDocumentor.required_param(*args)
    end
    
    def optional_param(*args)
      SelfDocumentor.optional_param(*args)
    end
        
    def self.required_param(*args)
      (@capture_required_param ||= []) << {args.first => args.last}
    end
    
    def self.optional_param(*args)
      args.unshift(:note) if args.size == 1
      (@capture_optional_param ||= []) << {args.first => args.last}
    end
    
    def self.capture(text)
      @capture = text
    end
    
    def self.route_added(verb, path, proc)
      if [:get, :post, :put, :delete].include?(verb.downcase.to_sym)
        document = {:path => path, :description => verb.upcase.to_sym.to_s + ": " + (@capture || '').to_s}
        document[:required] = @capture_required_param if @capture_required_param
        document[:optional] = @capture_optional_param if @capture_optional_param
        (@@document ||= []) << document
        @capture_optional_param = nil
        @capture_required_param = nil
      end
    end
    
    def self.output
      @@document
    end
  end
end