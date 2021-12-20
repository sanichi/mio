class Aoc::Y2021d18 < Aoc
  def answer(part)
    add(parse("[[[[4,3],4],4],[7,[[8,4],9]]][1,1"))
    "not yet done"
  end

  def parse(string)
    num = nil
    string.scan(/[\[\]0-9]/).each_with_object([]) do |c, nums|
      case c
      when '['
        if num
          num = num.insert
        else
          nums.push(num = Number.new)
        end
      when /[0-9]/
        num.insert(c.to_i)
      when ']'
        num = num.parent
      end
    end
  end

  def add(list)
    num = list.shift
    num = num.add(list.shift) while !list.empty?
    num
  end

  class Number
    attr_reader :left, :rite, :parent

    def initialize(parent=nil)
      @parent = parent
    end

    def insert(num=nil)
      num = Number.new(self) if num.nil?
      if left.nil?
        @left = num
      elsif rite.nil?
        @rite = num
      else
        raise "invalid input"
      end
      num
    end

    def add(rite)
      num = Number.new
      num.insert self
      num.insert rite
      num.reduce
    end

    def reduce
      self
    end

    def magnitude
      l = left.is_a?(Number) ? left.magnitude : left
      r = rite.is_a?(Number) ? rite.magnitude : rite
      3 * l + 2 * r
    end

    def to_s
      "[#{pair_to_s(left)},#{pair_to_s(rite)}]"
    end

    def pair_to_s(num)
      case num
      when Number
        num.to_s
      when nil
        "*"
      else
        num
      end
    end
  end

  EXAMPLE = <<~EOE
    [[[0,[5,8]],[[1,7],[9,6]]],[[4,[1,2]],[[1,4],2]]]
    [[[5,[2,8]],4],[5,[[9,9],0]]]
    [6,[[[6,2],[5,6]],[[7,6],[4,7]]]]
    [[[6,[0,7]],[0,9]],[4,[9,[9,0]]]]
    [[[7,[6,4]],[3,[1,3]]],[[[5,5],1],9]]
    [[6,[[7,3],[3,2]]],[[[3,8],[5,7]],4]]
    [[[[5,4],[7,7]],8],[[8,3],8]]
    [[9,3],[[9,9],[6,[4,9]]]]
    [[2,[[7,7],7]],[[5,8],[[9,3],[0,2]]]]
    [[[[5,2],5],[8,[3,7]]],[[5,[7,5]],[4,4]]]
  EOE

  EXAMPLE2 = <<~EOE
    [[1,2],[[3,4],5]]
    [[[[0,7],4],[[7,8],[6,0]]],[8,1]]
    [[[[1,1],[2,2]],[3,3]],[4,4]]
    [[[[3,0],[5,3]],[4,4]],[5,5]]
    [[[[5,0],[7,4]],[5,5]],[6,6]]
    [[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]]
  EOE
end
