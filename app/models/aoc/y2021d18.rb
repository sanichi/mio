class Aoc::Y2021d18 < Aoc
  def answer(part)
    numbers = parse(input)
    if part == 1
      numbers.reduce(&:+).mag
    else
      "not done yet"
    end
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

  class Number
    attr_reader :tree, :list

    def initialize(tree, list)
      @tree = tree
      @list = list
    end

    def +(n)   = Number.new(tree + n.tree, list + n.list).reduce
    def mag()  = tree.mag
    def reduce = explode && reduce || split && reduce || self

    def explode
      i = list.index {|t| t.level == 4}
      return false unless i
      t = list[i]
      unless t.parent && t.parent.rite == t && t.parent.add_rite(t.left)
        list[i-1].add_rite(t.left) if i > 0
      end
      unless t.parent && t.parent.left == t && t.parent.add_left(t.rite)
        list[i+1].add_left(t.rite) if i < list.length - 1
      end
      t.parent.zero(t) if t.parent
      if t.parent && t.parent.has_tree?
        list[i] = t.parent
      else
        list.slice!(i)
      end
      return true
    end

    def split
      i = list.index{|t| t.left > 9 || t.rite > 9}
      return false unless i
      t = list[i]
      trees = t.split
      @list = (i == 0 ? [] : list[0..i-1]) + trees + list[i+1..list.length]
      return true
    end

    def to_s
      "#{tree.to_s} #{list.map{|t| t.to_s(false)}.join}"
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

    def >(n) = false
    def is_num?(num) = num > -1
    def is_tree?(num) = !is_num?(num)
    def has_tree?() = is_tree?(left) || is_tree?(rite)

    def add_rite(num)
      if is_num?(rite)
        @children[1] += num
        true
      elsif is_num?(left)
        @children[0] += num
        true
      else
        false
      end
    end

    def add_left(num)
      if is_num?(left)
        @children[0] += num
        true
      elsif is_num?(rite)
        @children[1] += num
        true
      else
        false
      end
    end

    def zero(tree)
      @children[0] = 0 if left == tree
      @children[1] = 0 if rite == tree
    end

    def split
      trees = []
      tree = Tree.new(self)
      if left > 9
        tree.insert((left.to_f / 2.0).floor)
        tree.insert((left.to_f / 2.0).ceil)
        @children[0] = tree
        trees.push tree
        trees.push self if is_num?(rite)
      elsif rite > 9
        tree.insert((rite.to_f / 2.0).floor)
        tree.insert((rite.to_f / 2.0).ceil)
        @children[1] = tree
        trees.push(self) if is_num?(left)
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
      left.raise! if is_tree?(left)
      rite.raise! if is_tree?(rite)
      self
    end

    def mag
      l = is_tree?(left) ? left.mag : left
      r = is_tree?(rite) ? rite.mag : rite
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
    [6,[[[6,2],[5,6]],[[7,6],[4,7]]]]
    [[[6,[0,7]],[0,9]],[4,[9,[9,0]]]]
    [[[7,[6,4]],[3,[1,3]]],[[[5,5],1],9]]
    [[6,[[7,3],[3,2]]],[[[3,8],[5,7]],4]]
    [[[[5,4],[7,7]],8],[[8,3],8]]
    [[9,3],[[9,9],[6,[4,9]]]]
    [[2,[[7,7],7]],[[5,8],[[9,3],[0,2]]]]
    [[[[5,2],5],[8,[3,7]]],[[5,[7,5]],[4,4]]]
  EOE
end
