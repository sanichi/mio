class Aoc::Y2021d7 < Aoc
  def answer(part)
    if part == 1
      Crabs.new(input).minimum
    else
      "not done yet"
    end
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

    def minimum() = fuel(median)
    def fuel(m) = crabs.map{|c| (m - c).abs}.sum
  end

  EXAMPLE = "16,1,2,0,4,2,7,1,2,14"
end
