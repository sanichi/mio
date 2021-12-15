class Aoc::Y2021d15 < Aoc
  def answer(part)
    map = Map.new(EXAMPLE)
    "not done yet"
  end

  class Map
    attr_reader :risk, :width, :height

    def initialize(string)
      @risk = []
      @width = nil
      string.each_line do |line|
        row = line.scan(/\d/).map(&:to_i)
        raise "invalid row" unless row.size > 0
        if width
          raise "row has wrong length" unless width == row.size
        else
          @width = row.size
        end
        risk.push row
      end
      @height = @risk.size
      raise "not a square" unless height > 0 && height == width
    end
  end

  EXAMPLE = <<~EOE
    1163751742
    1381373672
    2136511328
    3694931569
    7463417111
    1319128137
    1359912421
    3125421639
    1293138521
    2311944581
  EOE
end
