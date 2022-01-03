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

    def cost(loc) = risk[loc[0]][loc[1]]

    def neighbours(loc)
      [[1,0],[0,1],[-1,0],[0,-1]].each do |dr,dc|
        r = loc[0] + dr
        c = loc[1] + dc
        yield [r,c] if r >=0 && r < height && c >= 0 && c < width
      end
    end

    def dijkstra
      que = Queue.new([0,0])
      target = [height-1,width-1]
      while !que.empty?
        node, score = que.min
        break score if node == target
        neighbours(node) do |near|
          que.add(near, score + cost(near))
        end
      end
    end

    def times5
      width5 = width * 5
      height5 = height * 5
      risk5 = Array.new(height5){Array.new(width5, 0)}
      (0..4).each do |i|
        (0..4).each do |j|
          (0..height-1).each do |r|
            (0..width-1).each do |c|
              risk5[r+i*height][c+j*width] = (i + j + risk[r][c] - 1).remainder(9) + 1
            end
          end
        end
      end
      @width = width5
      @height = height5
      @risk = risk5
      self
    end
  end

  class Queue
    def initialize(source)
      @queue = {}
      @visited = {}
      add(source, 0)
    end

    def empty? = @queue.empty?

    def add(loc, cost)
      unless @visited[loc] || (@queue.has_key?(loc) && @queue[loc] <= cost)
        @queue[loc] = cost
      end
    end

    def min
      min = loc = nil
      @queue.each_pair do |key, cost|
        if min.nil? || min > cost
          min = cost
          loc = key
        end
      end
      @visited[loc] = @queue.delete(loc)
      [loc, min]
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
