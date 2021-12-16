class Aoc::Y2021d15 < Aoc
  def answer(part)
    map = Map.new(input)
    if part == 1
      map.dijkstra
    else
      map.times5.dijkstra
    end
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

    # Dijkstra‘s algorithm but with simplifications:
    # 1. nodes and edges form a grid,
    # 2. cost of travelling to node is same for any edge.
    # This means the optimal path will only go to the
    # right or downwards, never to the left or upwards and
    # the implementation is simpler than the general case.
    def dijkstra
      cost = Array.new(height){Array.new(width, 0)}
      (1..height-1).each{|r| cost[r][0] = cost[r-1][0] + risk[r][0]}
      (1..width-1).each{|c| cost[0][c] = cost[0][c-1] + risk[0][c]}
      (1..height-1).each do |r|
        (1..width-1).each do |c|
          cost[r][c] = risk[r][c] + [cost[r-1][c], cost[r][c-1]].min
        end
      end
      cost[width-1][height-1]
    end

    def times5
      new_risk = Array.new(height * 5){Array.new(width * 5, 0)}
      (0..4).each do |i|
        (0..4).each do |j|
          (0..height-1).each do |r|
            (0..width-1).each do |c|
              new_risk[r+i*height][c+j*width] = (i + j + risk[r][c] - 1).remainder(9) + 1
            end
          end
        end
      end
      @risk = new_risk
      @width = width * 5
      @height = height * 5
      self
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
