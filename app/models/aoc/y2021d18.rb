class Aoc::Y2021d18 < Aoc
  def answer(part)
    numbers = parse("[1,2][3,4]")
    add(numbers).to_list_s
    "not done yet"
  end

  def parse(string)
    tree = nil
    list = []
    string.scan(/[\[\]0-9]/).each_with_object([]) do |c, numbers|
      case c
      when '['
        if tree
          tree = tree.insert
        else
          tree = Tree.new
        end
      when /[0-9]/
        tree.insert(c.to_i)
        list.push(tree) unless list.last == tree
      when ']'
        if tree.parent.nil?
          numbers.push(Number.new(tree, list))
          list = []
        end
        tree = tree.parent
      end
    end
  end

  def add(numbers)
    number = numbers.shift
    while !numbers.empty?
      next_number = numbers.shift
      tree = number.tree.add(next_number.tree)
      list = number.list + next_number.list
      number = Number.new(tree, list)
    end
    number
  end

  class Number
    attr_reader :tree, :list

    def initialize(tree, list)
      @tree = tree
      @list = list
    end

    def to_tree_s
      tree.to_s
    end

    def to_list_s
      list.map{|t| t.to_s(true)}.join
    end
  end

  class Tree
    attr_reader :left, :rite, :parent, :level

    def initialize(parent=nil)
      @parent = parent
      @level = parent ? parent.level + 1 : 0
    end

    def insert(tree=nil)
      tree = Tree.new(self) if tree.nil?
      if left.nil?
        @left = tree
      elsif rite.nil?
        @rite = tree
      else
        raise "invalid input"
      end
      tree
    end

    def add(rite)
      tree = Tree.new
      tree.insert(self.raise)
      tree.insert(rite.raise)
      tree.reduce
    end

    def raise
      @level += 1
      left.raise if left.is_a?(Tree)
      rite.raise if rite.is_a?(Tree)
      self
    end

    def reduce
      self
    end

    def magnitude
      l = left.is_a?(Tree) ? left.magnitude : left
      r = rite.is_a?(Tree) ? rite.magnitude : rite
      3 * l + 2 * r
    end

    def to_s(list=false)
      if list
        "[#{num_or_none(left)},#{num_or_none(rite)}:#{level}]"
      else
        "[#{num_or_tree(left)},#{num_or_tree(rite)}:#{level}]"
      end
    end

    def num_or_tree(num)
      case num
      when Tree
        num.to_s
      when nil
        "*"
      else
        num
      end
    end

    def num_or_none(num)
      case num
      when Tree
        "."
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
