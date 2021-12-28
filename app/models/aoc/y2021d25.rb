class Aoc::Y2021d25 < Aoc
  def answer(part)
    if part == 1
      Cucumbers.new(input).steps
    else
      "no part two for this day"
    end
  end

  class Cucumbers
    attr_reader :locs, :rows, :cols

    def initialize(string)
      @locs = {}
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
      east = {}
      each_cell do |r,c|
        if locs[[r,c]] == ">"
          n = c + 1
          n = 0 if n == cols
          if locs[[r,n]] == "."
            east[[r,n]] = ">"
            east[[r,c]] = "."
            moves += 1
          else
            east[[r,c]] = ">"
          end
        else
          east[[r,c]] = locs[[r,c]] unless east[[r,c]]
        end
      end
      @locs = east
      south = {}
      each_cell do |r,c|
        if locs[[r,c]] == "v"
          n = r + 1
          n = 0 if n == rows
          if locs[[n,c]] == "."
            south[[n,c]] = "v"
            south[[r,c]] = "."
            moves += 1
          else
            south[[r,c]] = "v"
          end
        else
          south[[r,c]] = locs[[r,c]] unless south[[r,c]]
        end
      end
      @locs = south
      moves
    end

    def each_cell
      (0..rows-1).each do |r|
        (0..cols-1).each do |c|
          yield [r,c]
        end
      end
    end
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
