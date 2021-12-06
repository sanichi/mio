class Aoc::Y2021d5 < Aoc
  def answer(part)
    lines = parse(input)
    if part == 1
      dangerous(lines, false)
    else
      dangerous(lines, true)
    end
  end

  def parse(string)
    string.scan(/(\d+),(\d+) -> (\d+),(\d+)/).map do |x1,y1,x2,y2|
      Line.new(x1,y1,x2,y2)
    end
  end

  def dangerous(lines, all)
    h = Hash.new(0)
    lines.each do |line|
      if all || line.horizontal? || line.vertical?
        line.each_point do |p|
          h[p] += 1
        end
      end
    end
    h.values.filter{|v| v > 1}.size
  end

  class Line
    attr_reader :x1, :y1, :x2, :y2

    def initialize(x1, y1, x2, y2)
      @x1 = x1.to_i
      @y1 = y1.to_i
      @x2 = x2.to_i
      @y2 = y2.to_i
    end

    def horizontal?
      y1 == y2
    end

    def vertical?
      x1 == x2
    end

    def each_point
      dx = x1 == x2 ? 0 : (x1 < x2 ? 1 : -1)
      dy = y1 == y2 ? 0 : (y1 < y2 ? 1 : -1)
      max = [(x1 - x2).abs, (y1 - y2).abs].max
      (0..max).each{|i| yield "#{x1 + i * dx}_#{y1 + i * dy}"}
    end
  end

  EXAMPLE = <<~EOE
    0,9 -> 5,9
    8,0 -> 0,8
    9,4 -> 3,4
    2,2 -> 2,1
    7,0 -> 7,4
    6,4 -> 2,0
    0,9 -> 2,9
    3,4 -> 1,4
    0,0 -> 8,8
    5,5 -> 8,2
  EOE
end
