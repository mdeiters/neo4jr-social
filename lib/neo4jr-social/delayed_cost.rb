module Neo4jr
  class DelayedCost
    attr_accessor :relationship, :cost
    def initialize relationship, cost=0.0
      self.relationship = relationship
      self.cost=cost
    end
  end
end