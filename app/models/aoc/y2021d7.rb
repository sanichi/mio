class Aoc::Y2021d7 < Aoc
  def answer(part)
    Crabs.new(input).send(part == 1 ? :med_minimum : :ave_minimum)
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

    def average() = (crabs.sum.to_f / crabs.size.to_f).floor
    def med_minimum() = med_fuel(median)
    def ave_minimum() = ave_fuel(average)
    def med_fuel(m) = crabs.map{|c| (m - c).abs}.sum
    def ave_fuel(m) = crabs.map{|c| d = (m - c).abs; (d + 1) * d / 2}.sum
  end

  EXAMPLE = "16,1,2,0,4,2,7,1,2,14"
end
