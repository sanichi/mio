class Relation
  attr_reader :type, :grand, :degree, :removal, :law

  def initialize(type, grand: 0, degree: 0, removal: 0, law: false)
    @type, @grand, @degree, @removal, @law = type, grand, degree, removal, law
  end

  def self.infer(my_ancestor, their_ancestor, male)
    return new(:none) unless my_ancestor && their_ancestor
    my_depth, their_depth = my_ancestor.connections, their_ancestor.connections
    blood = [my_ancestor, their_ancestor].select{ |a| a.blood }.size
    opt = {}
    type =
    case
    when my_depth == 0 && their_depth == 0 && blood > 0
      blood == 2 ? :self : (male ? :husband : :wife)
    when my_depth > 0 && their_depth == 0
      opt[:grand] = my_depth - 1
      opt[:law] = blood < 2
      male ? :son : :daughter
    when my_depth == 0 && their_depth > 0
      opt[:grand] = their_depth - 1
      opt[:law] = blood < 2
      male ? :father : :mother
    when my_depth == 1 && their_depth == 1
      opt[:law] = blood < 2
      male ? :brother : :sister
    when my_depth > 1 && their_depth == 1
      opt[:grand] = my_depth - 1
      male ? :nephew : :niece
    when my_depth == 1 && their_depth > 1
      opt[:grand] = their_depth - 1
      male ? :uncle : :aunt
    when my_depth >= 2 && their_depth >= 2
      opt[:degree] = [my_depth, their_depth].min - 1
      opt[:removal] = (my_depth - their_depth).abs
      :cousin
    else
      :none
    end
    new(type, opt)
  end

  def to_s(caps: false)
    str = case type
          when :self
            "self"
          when :none
            "no relation"
          when :father, :mother, :son, :daughter
            great_part + grand_part + type.to_s + law_part
          when :uncle, :aunt, :nephew, :niece
            great_part + type.to_s
          when :brother, :sister
            type.to_s + law_part
          when :cousin
            degree_part + type.to_s + removal_part
          else
            type.to_s
          end
    caps ? str.gsub(/[a-z]+/, &:capitalize) : str
  end

  private

  def great_part
    grand > 1 ? "great-" * (grand - 1) : ""
  end

  def grand_part
    grand > 0 ? "grand" : ""
  end

  def degree_part
    case degree
    when 1 then "1st "
    when 2 then "2nd "
    when 3 then "3rd "
    else "#{degree}th "
    end
  end

  def removal_part
    case removal
    when 0 then ""
    when 1 then " once removed"
    when 2 then " twice removed"
    else "#{removal}-times removed"
    end
  end

  def law_part
    law ? "-in-law" : ""
  end
end
