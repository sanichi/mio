class Aoc::Y2021d11 < Aoc
  def answer(part)
    octopuses = Octopuses.new(input)
    if part == 1
      octopuses.flashes_after_steps(100)
    else
      octopuses.steps_until_all_flashing
    end
  end

  class Octopuses
    attr_reader :rows, :width, :height, :flashes

    def initialize(string)
      @width = nil
      @rows = string.each_line.map do |line|
        cols = line.scan(/\d/).map(&:to_i)
        if @width
          raise "invalid input" unless @width == cols.length
        else
          @width = cols.length
        end
        cols
      end
      @height = @rows.length
      @flashes = 0
    end

    def flashes_after_steps(n)
      n.times {step}
      flashes
    end

    def steps_until_all_flashing
      n = 0
      while !simultaneous?
        step
        n += 1
      end
      n
    end

    private

    def step
      scan{|r,c| rows[r][c] += 1}
      flash
    end

    def flash
      flashes = 0
      scan do |r,c|
        if rows[r][c] > 9
          flashes += 1
          rows[r][c] = 0
          neighbours(r,c){|nr,nc| rows[nr][nc] += 1 unless rows[nr][nc] == 0}
        end
      end
      if flashes > 0
        @flashes += flashes
        flash
      end
    end

    def simultaneous?
      scan{|r,c| return false if rows[r][c] > 0}
      true
    end

    def scan
      (0..height-1).each do |r|
        (0..width-1).each do |c|
          yield r, c
        end
      end
    end

    def neighbours(r,c)
      [[1,0],[1,-1],[0,-1],[-1,-1],[-1,0],[-1,1],[0,1],[1,1]].each do |dr,dc|
        nr = r + dr
        nc = c + dc
        next unless nr >= 0 && nr < height && nc >= 0 && nc < width
        yield r + dr, c + dc
      end
    end
  end

  EXAMPLE = <<~EOE
    5483143223
    2745854711
    5264556173
    6141336146
    6357385478
    4167524645
    2176841721
    6882881134
    4846848554
    5283751526
  EOE
end
