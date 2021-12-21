class Aoc::Y2021d18 < Aoc
  def answer(part)
    parse("[1,1][2,2][3,3][4,4][5,5][6,6]").to_s
    "not finished yet"
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
    end.reduce(&:+)
  end

  class Number
    attr_reader :tree, :list

    def initialize(tree, list)
      @tree = tree
      @list = list
    end

    def mag() = tree.mag
    def +(n)
      Rails.logger.info "self #{to_s} #{to_s(false)}"
      Rails.logger.info "next #{n.to_s} #{n.to_s(false)}"
      befo = Number.new(tree + n.tree, list + n.list)
      Rails.logger.info "befo #{befo.to_s} #{befo.to_s(false)}"
      aftr = befo.reduce
      Rails.logger.info "aftr #{aftr.to_s} #{aftr.to_s(false)}"
      aftr
    end

    def reduce
      if explode
        reduce
      else
        if split
          reduce
        else
          self
        end
      end
    end

    def explode
      i = list.index {|t| t.level == 4}
      return false unless i
      t = list[i]
      list[i-1].add_rite(t.left) if i > 0
      list[i+1].add_left(t.rite) if i < list.length - 1
      t.parent.zero(t) if t.parent
      list.slice!(i)
      return true
    end

    def split
      i = list.index{|t| (!t.left.is_a?(Tree) && t.left > 9) || (!t.rite.is_a?(Tree) && t.rite > 9)}
      return false unless i
      t = list[i]
      trees = t.split
      @list = (i == 0 ? [] : list[0..i-1]) + trees + list[i+1..list.length]
      return true
    end

    def to_s(recursive=true)
      if recursive
        tree.to_s
      else
        list.map{|t| t.to_s(false)}.join
      end
    end
  end

  class Tree
    attr_reader :parent, :children, :level

    def initialize(parent=nil)
      @parent = parent
      @children = []
      @level = parent ? parent.level + 1 : 0
    end

    def left() = children[0]
    def rite() = children[1]

    def add_rite(num)
      if !rite.is_a?(Tree)
        @children[1] += num
      elsif !left.is_a?(Tree)
        @children[0] += num
      end
    end

    def add_left(num)
      if !left.is_a?(Tree)
        @children[0] += num
      elsif !rite.is_a?(Tree)
        @children[1] += num
      end
    end

    def zero(tree)
      @children[0] = 0 if left == tree
      @children[1] = 0 if rite == tree
    end

    def split
      trees = []
      tree = Tree.new(self)
      if !left.is_a?(Tree) && left > 9
        tree.insert((left.to_f / 2.0).floor)
        tree.insert((left.to_f / 2.0).ceil)
        @children[0] = tree
        trees.push tree
        trees.push self if !rite.is_a?(Tree)
      elsif !rite.is_a?(Tree) && rite > 9
        tree.insert((rite.to_f / 2.0).floor)
        tree.insert((rite.to_f / 2.0).ceil)
        @children[1] = tree
        trees.push(self) if !left.is_a?(Tree)
        trees.push tree
      end
      trees
    end

    def insert(tree=nil)
      tree = Tree.new(self) if tree.nil?
      if children.length < 2
        children.push tree
      else
        raise "too many children"
      end
      tree
    end

    def +(tree)
      parent = Tree.new
      parent.insert(self.raise!(parent))
      parent.insert(tree.raise!(parent))
      parent
    end

    def raise!(parent=nil)
      @parent = parent if parent
      @level += 1
      left.raise!() if left.is_a?(Tree)
      rite.raise!() if rite.is_a?(Tree)
      self
    end

    def mag
      l = left.is_a?(Tree) ? left.mag : left
      r = rite.is_a?(Tree) ? rite.mag : rite
      3 * l + 2 * r
    end

    def to_s(recursive=true)
      pair =
        children.map do |child|
          case child
          when Tree
            recursive ? child.to_s : "*"
          when nil
            "-"
          else
            child
          end
        end
      "[#{pair.join(',')}:#{level}:#{self&.parent ? 'p' : 'x'}]"
    end
  end

  EXAMPLE = <<~EOE
    [[[0,[5,8]],[[1,7],[9,6]]],[[4,[1,2]],[[1,4],2]]]
    [[[5,[2,8]],4],[5,[[9,9],0]]]
  EOE
  #   [6,[[[6,2],[5,6]],[[7,6],[4,7]]]]
  #   [[[6,[0,7]],[0,9]],[4,[9,[9,0]]]]
  #   [[[7,[6,4]],[3,[1,3]]],[[[5,5],1],9]]
  #   [[6,[[7,3],[3,2]]],[[[3,8],[5,7]],4]]
  #   [[[[5,4],[7,7]],8],[[8,3],8]]
  #   [[9,3],[[9,9],[6,[4,9]]]]
  #   [[2,[[7,7],7]],[[5,8],[[9,3],[0,2]]]]
  #   [[[[5,2],5],[8,[3,7]]],[[5,[7,5]],[4,4]]]
  # EOE

  EXAMPLE2 = <<~EOE
    [[1,2],[[3,4],5]]
    [[[[0,7],4],[[7,8],[6,0]]],[8,1]]
    [[[[1,1],[2,2]],[3,3]],[4,4]]
    [[[[3,0],[5,3]],[4,4]],[5,5]]
    [[[[5,0],[7,4]],[5,5]],[6,6]]
    [[[[8,7],[7,7]],[[8,6],[7,7]]],[[[0,7],[6,6]],[8,7]]]
  EOE
end
