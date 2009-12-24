module Neo4jr
  class SimpleEvaluator
    include org.neo4j.graphalgo.shortestpath.CostEvaluator

    def getCost(relationship, backwards)
      1.0
    end
  end
end