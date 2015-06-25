class Relation
  attr_reader :type, :grand, :degree, :removal

  def initialize(type, grand: 0, degree: 0, removal: 0)
    @type, @grand, @degree, @removal = type, grand, degree, removal
  end

  def self.infer(my_level, their_level, male)
    return new(:none) unless my_level
    opts = {}
    type =
    case
    when my_level == 0 && their_level == 0
      :self
    when my_level > 0 && their_level == 0
      opts[:grand] = my_level - 1
      male ? :son : :daughter
    when my_level == 0 && their_level > 0
      opts[:grand] = their_level - 1
      male ? :father : :mother
    when my_level == 1 && their_level == 1
      male ? :brother : :sister
    when my_level > 1 && their_level == 1
      opts[:grand] = my_level - 1
      male ? :nephew : :niece
    when my_level == 1 && their_level > 1
      opts[:grand] = their_level - 1
      male ? :uncle : :aunt
    when my_level >= 2 && their_level >= 2
      opts[:degree] = [my_level, their_level].min - 1
      opts[:removal] = (my_level - their_level).abs
      :cousin
    else
      :none
    end
    new(type, opts)
  end

  def to_s(caps: false)
    str = case type
          when :self
            "self"
          when :none
            "no relation"
          when :father, :mother, :son, :daughter
            great_part + grand_part + type.to_s
          when :uncle, :aunt, :nephew, :niece
            great_part + type.to_s
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
end
