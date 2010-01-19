module Neo4jr
  class DelayedCostComparator
    include java.util.Comparator

    def compare(o1, o2)
      o1.cost == o2.cost ? nvl(o1.relationship) <=> nvl(o2.relationship) : o1.cost <=> o2.cost
    end

    private
    def nvl a
      a.nil? ? 0 : 1
    end
  end
end