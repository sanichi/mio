class Aoc::Y2021d17 < Aoc
  def answer(part) = Target.new(input).send(part == 1 ? :best : :hits)

  class Target
    include Enumerable
    attr_reader :x1, :x2, :y1, :y2

    def initialize(string)
      if string.match(/target area: x=(\d+)\.\.(\d+), y=(-\d+)\.\.(-\d+)/)
        @x1, @x2, @y1, @y2 = [$1.to_i, $2.to_i, $3.to_i, $4.to_i]
      end
      raise "invalid input" unless x1 && x1 < x2 && y1 < y2
    end

    def best() = reduce(0){|sofar, max| max.nil? || sofar >= max ? sofar : max}
    def hits() = reduce(0){|count, max| max.nil? ? count : count + 1}

    private

    def each
      min_vx = (Math.sqrt(1 + 8 * x1).floor - 1) / 2 # solve quadratic to get lowest x-velocity
      max_vx = x2 # any faster (rightwards) and it will shoot past on the first step
      min_vy = y1 # any faster (downwards) and it will shoot past on the first step
      max_vy = 2000 # compromise: large enough for right answers, not too large for compute time
      (min_vx..max_vx).each do |vx|
        (min_vy..max_vy).each do |vy|
          yield step(vx,vy,0,0,0)
        end
      end
    end

    def step(vx, vy, x, y, max)
      x += vx
      y += vy
      max = y if y > max

      return max if x >= x1 && x <= x2 && y >= y1 && y <= y2
      return nil if vx == 0 && (x < x1 || x > x2)
      return nil if y <= y1 && vy <= 0

      vx += vx == 0 ? 0 : (vx > 0 ? -1 : 1)
      vy -= 1

      step(vx, vy, x, y, max)
    end
  end

  EXAMPLE = "target area: x=20..30, y=-10..-5"
end
