class Ancestors
  attr_reader :collection

  Ancestor = Struct.new(:person, :level)

  def initialize(person)
    @collection = { person.id => Ancestor.new(person, 0) }
    expand(0)
  end

  def lowest_common_ancestor(other)
    s1 = Set.new(collection.keys)
    s2 = Set.new(other.collection.keys)
    common = (s1 & s2).to_a.map{ |id| collection[id] }.sort{ |a,b| a.level <=> b.level }
    common.reject!{ |ancestor| ancestor.level > common[0].level } if common.any?
    common.map(&:person).sort{ |a,b| a.born <=> b.born }
  end

  private

  def expand(level)
    this_level = collection.values.select { |ancestor| ancestor.level == level }
    more = false
    this_level.each do |ancestor|
      if (father = ancestor.person.father) && !collection[father.id]
        collection[father.id] = Ancestor.new(father, level + 1)
        more = true
      end
      if (mother = ancestor.person.mother) && !collection[mother.id]
        collection[mother.id] = Ancestor.new(mother, level + 1)
        more = true
      end
    end
    expand(level + 1) if more
  end
end
