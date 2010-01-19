module Neo4jr
  class DelayedCostEvaluator
    include org.neo4j.graphalgo.shortestpath.CostEvaluator

    def getCost(relationship, backwards)
      DelayedCost.new relationship
    end
  end
end