class Aoc::Y2021d9 < Aoc
  def answer(part) = Map.new(input).send(part == 1 ? :risk : :basins)

  class Map
    attr_reader :data, :height, :width

    def initialize(string)
      @width = nil
      @data = string.each_line.map do |line|
        row = line.scan(/\d/).map(&:to_i)
        if @width
          raise "bad data" unless row.size == @width
        else
          @width = row.size
        end
        row
      end
      @height = @data.size
    end

    def risk
      lows.map{|r,c| data[r][c] + 1}.sum
    end

    def basins
      lows.map{|r,c| size(r,c)}.sort.last(3).reduce(&:*)
    end

    def lows
      (0..height-1).reduce([]) do |s, r|
        s + (0..width-1).reduce([]) do |t, c|
          val = data[r][c]
          low = true
          neighbours(r,c).each do |nr,nc|
            if data[nr][nc] <= val
              low = false
              break
            end
          end
          t.push([r,c]) if low
          t
        end
      end
    end

    def size(r, c)
      basin = {[r,c] => false}
      grow(basin)
      basin.size
    end

    def grow(basin)
      unchecked = basin.filter{|_,val| !val}
      return if unchecked.empty?
      unchecked.keys.each do |r,c|
        neighbours(r,c).each do |nr,nc|
          basin[[nr,nc]] = false unless data[nr][nc] == 9 || basin.has_key?([nr,nc])
        end
        basin[[r,c]] = true
      end
      grow(basin)
    end

    def neighbours(r,c)
      [[-1,0],[1,0],[0,-1],[0,1]].map do |dr,dc|
        nr = r + dr
        nc = c + dc
        if nr >= 0 && nr < height && nc >= 0 && nc < width
          [nr,nc]
        else
          nil
        end
      end.compact
    end
  end

  EXAMPLE = <<~EOE
    2199943210
    3987894921
    9856789892
    8767896789
    9899965678
  EOE
end
