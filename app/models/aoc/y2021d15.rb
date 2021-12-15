class Aoc::Y2021d15 < Aoc
  def answer(part)
    map = Map.new(input)
    if part == 1
      map.dijkstra
    else
      map.times5.dijkstra
      "not got the right answer yet"
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

    def translate
      matrix = []
      n = 0
      (0..height-1).each do |r|
        (0..width-1).each do |c|
          rn = r - 1
          cn = c
          nn = n - width
          matrix.push [nn, n, risk[r][c]] if rn >= 0
          re = r
          ce = c - 1
          ne = n - 1
          matrix.push [ne, n, risk[r][c]] if ce >= 0
          n += 1
        end
      end
      ob = Dijkstra.new(0, n, matrix)
      ob.cost
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

  # Class that calculates the smallest path using Dijkstra Algorithm
  # from https://github.com/thinkphp/dijkstra.gem/blob/master/lib/dijkstra.rb
  class Dijkstra
    # constructor of the class
    def initialize(startpoint, endpoint, matrix_of_road)
      # start node
      @start = startpoint
      # end node
      @end = endpoint
      @path = []
      @infinit = Float::INFINITY
      # Recreating matrix_of_road to avoid passing the number
      # of vertices in the first element.
      vertices = number_of_vertices(matrix_of_road.dup)
      matrix_of_road =  matrix_of_road.unshift([vertices])
      read_and_init(matrix_of_road)
      # Dijkstra's algorithm in action and good luck
      dijkstra
    end
    # Calculates the number of vertices (unique elements)
    # in a matrix of road
    def number_of_vertices(matrix)
      # Ignoring the weight element (third element)
      matrix = matrix.collect { |x| [x[0], x[1]] }
      # Merging all the path arrays
      matrix = matrix.zip.flatten.compact
      # All the vertices
      @nodes = matrix.uniq.dup
      # Returning the number of unique elements (vertices)
      matrix.uniq.count
    end
    # This method determines the minimum cost of the shortest path
    def cost
      @r[@end]
    end
    # get the shortest path
    def shortest_path
      road(@end)
      @path
    end
    def road(node)
      road(@f[node]) if @f[node] != 0
      @path.push(node)
    end
    def dijkstra
      min = @infinit
      pos_min = @infinit
      @nodes.each do |i|
        @r[i] = @road[[@start, i]]
        @f[i] = @start if i != @start && @r[i] < @infinit
      end
      @s[@start] = 1
      @nodes[0..@nodes.size - 2].each do
        min = @infinit
        @nodes.each do |i|
          if @s[i] == 0 && @r[i] < min
            min = @r[i]
            pos_min = i
          end
        end
        @s[pos_min] = 1
        @nodes.each do|j|
          if @s[j] == 0
            if @r[j] > @r[pos_min] + @road[[pos_min, j]]
              @r[j] = @r[pos_min] + @road[[pos_min, j]]
              @f[j] = pos_min
            end
          end
        end
      end
    end
    def read_and_init(arr)
      n = arr.size - 1
      @road = Hash.new(@nodes)
      @r = Hash.new(@nodes)
      @s = Hash.new(@nodes)
      @f = Hash.new(@nodes)
      @nodes.each do |i|
        @r[i] = 0
      end
      @nodes.each do |i|
        @s[i] = 0
      end
      @nodes.each do |i|
        @f[i] = 0
      end
      @nodes.each do |i|
        @nodes.each do |j|
          if i == j
            @road[[i, j]] = 0
          else
            @road[[i, j]] = @infinit
          end
        end
      end
      (1..n).each do |i|
        x = arr[i][0]
        y = arr[i][1]
        c = arr[i][2]
        @road[[x, y]] = c
      end
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
