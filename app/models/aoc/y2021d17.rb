class Aoc::Y2021d17 < Aoc
  def answer(part)
    target = Target.new(input)
    if part == 1
      target.highest
    else
      "not done yet"
    end
  end

  class Target
    attr_reader :x1, :x2, :y1, :y2

    def initialize(string)
      if string.match(/\Atarget area: x=(\d+)\.\.(\d+), y=(-\d+)\.\.(-\d+)/)
        @x1, @x2, @y1, @y2 = [$1.to_i, $2.to_i, $3.to_i, $4.to_i]
      end
      raise "invalid input" unless @x1 && @x1 < @x2 && @y1 < @y2
    end

    def highest
      min_vx = (Math.sqrt(1 + 8 * x1).floor - 1) / 2 # solve quadratic to get lowest x-velocity
      max_vx = x2 # any faster (rightwards) and it will shoot past on the first step
      min_vy = y2 # any faster (downwards) and it will shoot past on the first step
      max_vy = y2 + 2000 # as large as I could go and still have it take only a few seconds
      max = 0
      (min_vx..max_vx).each do |vx|
        (min_vy..max_vy).each do |vy|
          cur = step(vx,vy,0,0,0)
          max = cur if !cur.nil? && cur > max
        end
      end
      max
    end

    private

    def step(vx, vy, x, y, max)
      x += vx
      y += vy
      max = y if y > max

      return max  if x >= x1 && x <= x2 && y >= y1 && y <= y2
      return nil if vx == 0 && (x < x1 || x2 < x)
      return nil if y < y1 && vy < 0

      vx += (vx == 0 ? 0 : (vx > 0 ? -1 : 1))
      vy -= 1

      step(vx, vy, x, y, max)
    end
  end

  EXAMPLE = "target area: x=20..30, y=-10..-5"
end
