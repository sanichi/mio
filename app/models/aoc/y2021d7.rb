class Aoc::Y2021d7 < Aoc
  def answer(part)
    Crabs.new(input).send(part == 1 ? :mdn_minimum : :avg_minimum)
  end

  class Crabs
    attr_reader :crabs

    def initialize(string)
      @crabs = string.scan(/\d+/).map(&:to_i)
    end

    def median
      s = crabs.sort
      h = crabs.size / 2
      if s.size.odd?
        s[h]
      else
        ((s[h-1] + s[h]).to_f / 2.0).round
      end
    end

    def average() = (crabs.sum.to_f / crabs.size).floor
    def mdn_fuel(m) = crabs.map{|c| (m - c).abs}.sum
    def avg_fuel(m) = crabs.map{|c| d = (m - c).abs; (d + 1) * d}.sum / 2
    def mdn_minimum() = mdn_fuel(median)
    def avg_minimum() = avg_fuel(average)
  end

  EXAMPLE = "16,1,2,0,4,2,7,1,2,14"
end
