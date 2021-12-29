class Aoc::Y2021d25 < Aoc
  def answer(part)
    if part == 1
      Cucumbers.new(input).steps
    else
      "no part two for this day"
    end
  end

  class Cucumbers
    attr_reader :locs, :rows, :cols, :tmps

    def initialize(string)
      @locs = {}
      @tmps = {}
      @cols = nil
      @rows = nil
      string.each_line.each_with_index do |line, r|
        @rows = r + 1
        data = line.scan(/[>v.]/)
        if cols.nil?
          @cols = data.length
        else
          raise "wrong number of colums" unless cols == data.length
        end
        data.each_with_index{|d,c| locs[[r,c]] = d}
      end
      raise "invalid input" unless !rows.nil? && rows > 0 && !cols.nil? && cols > 0
    end

    def steps
      count = 1
      count += 1 while step > 0
      count
    end

    private

    def step
      moves = 0
      each_loc do |r,c|
        if eql(r,c,">") && (e = east(c)) && eql(r,e,".")
          set(r,e,">")
          set(r,c,".")
          moves += 1
        else
          copy(r,c)
        end
      end
      swap
      each_loc do |r,c|
        if eql(r,c,"v") && (s = south(r)) && eql(s,c,".")
          set(s,c,"v")
          set(r,c,".")
          moves += 1
        else
          copy(r,c)
        end
      end
      swap
      moves
    end

    def each_loc
      (0..rows-1).each do |r|
        (0..cols-1).each do |c|
          yield [r,c]
        end
      end
    end

    def eql(r,c,d) = locs[[r,c]] == d
    def set(r,c,d) = tmps[[r,c]] = d
    def copy(r,c)  = tmps[[r,c]] ||= locs[[r,c]]
    def east(c)    = c == cols - 1 ? 0 : c + 1
    def south(r)   = r == rows - 1 ? 0 : r + 1
    def swap       = (@locs = tmps) && (@tmps = {})
  end

  EXAMPLE = <<~EOE
    v...>>.vv>
    .vv>>.vv..
    >>.>v>...v
    >>v>>.>.v.
    v>v.vv.v..
    >.>>..v...
    .vv..>.>v.
    v.v..>>v.v
    ....v..v.>
  EOE
end
