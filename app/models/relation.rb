class Relation
  attr_reader :type, :grand

  def initialize(type, grand=0)
    @type, @grand = type, grand || 0
  end
  
  def self.infer(my_level, their_level, male)
    return new(:none) unless my_level
    type =
    case
    when my_level == 0 && their_level == 0
      :self
    when my_level == 0 && their_level > 0
      grand = their_level - 1
      male ? :son : :daughter
    when my_level > 0 && their_level == 0
      grand = my_level - 1
      male ? :father : :mother
    when my_level == 1 && their_level == 1
      male ? :brother : :sister
    when my_level == 2 && their_level == 2
      :cousin
    else
      :none
    end
    new(type, grand)
  end

  def to_s
    case type
    when :self
      "identity"
    when :none
      "no relation"
    when :father, :mother, :son, :daughter
      (grand > 1 ? "great-" * (grand - 1) : '') + (grand > 0 ? "grand" : '') + type.to_s
    else
      type.to_s
    end
  end
end
