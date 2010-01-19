module Neo4jr
  class DelayedCostAccumulator
    include org.neo4j.graphalgo.shortestpath.CostAccumulator

    def initialize
      @disjunct_cost = 1000.0
    end

    def addCosts(o1, o2)
      r1 = o1.relationship
      r2 = o2.relationship
      if r1 and r2
        DelayedCost nil, o1.cost + o2.cost + overlap_cost(r1, r2)
      else
        DelayedCost.new(r1 || r2, o1.cost + o2.cost)
      end
    end

    def overlap_cost r1, r2
      raise "Cannot add cost for non adjacent paths" unless r1.getEndNode == r2.getEndNode
      days = darr(:end_date, r1, r2).min - darr(:start_date, r1, r2).max
      days > 0 ? 1.0/days : @disjunct_cost
    end

    private
    def darr property, *rels
      rels.map {|r| (p=r.getProperty(property.to_s)) ? Date.parse(p, true) : Date.today}
    end
  end
end