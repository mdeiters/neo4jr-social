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
        DelayedCost.new(nil, o1.cost + o2.cost + overlap_cost(r1, r2))
      else
        DelayedCost.new(r1 || r2, o1.cost + o2.cost)
      end
    end

    def overlap_cost r1, r2
#      raise "Cannot add cost for non adjacent paths" unless r1.getEndNode == r2.getEndNode
      days = darr('end_date', r1, r2, true) - darr('start_date', r1, r2, false)
      days > 0 ? 1.0/days : @disjunct_cost
    end

    private
    def darr property, r1, r2, min
      d1 = Date.parse(r1.getProperty(property), true)
      d2 = Date.parse(r2.getProperty(property), true)

      if d1 < d2
          min ? d1 : d2
      else
          min ? d2 : d1
      end
    end
  end
end