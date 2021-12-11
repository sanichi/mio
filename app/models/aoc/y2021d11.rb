class Aoc::Y2021d11 < Aoc
  def answer(part)
    octopuses = Octopuses.new(input)
    if part == 1
      octopuses.count_flashes_after_steps(100)
    else
      octopuses.count_steps_until_all_flashing
    end
  end

  class Octopuses
    attr_reader :rows, :width, :height, :flashes

    NEIGHBOURS = [[1,0],[1,-1],[0,-1],[-1,-1],[-1,0],[-1,1],[0,1],[1,1]]

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

    def count_flashes_after_steps(n)
      n.times {step}
      flashes
    end

    def count_steps_until_all_flashing
      n = 0
      while !simultaneous?
        step
        n += 1
      end
      n
    end

    private

    def step
      (0..height-1).each do |r|
        (0..width-1).each do |c|
          rows[r][c] += 1
        end
      end
      flash
    end

    def flash
      flashes = 0
      (0..height-1).each do |r|
        (0..width-1).each do |c|
          if rows[r][c] > 9
            flashes += 1
            rows[r][c] = 0
            NEIGHBOURS.each do |dr,dc|
              nr = r + dr
              nc = c + dc
              if nr >= 0 && nr < height && nc >= 0 && nc < width && rows[nr][nc] != 0
                rows[nr][nc] += 1
              end
            end
          end
        end
      end
      if flashes > 0
        @flashes += flashes
        flash
      end
    end

    def simultaneous?
      (0..height-1).each do |r|
        (0..width-1).each do |c|
          return false if rows[r][c] > 0
        end
      end
      true
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
