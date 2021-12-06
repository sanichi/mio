class Aoc::Y2021d6 < Aoc
  def answer(part)
    Fish.new(input).days(part == 1 ? 80 : 256).count
  end

  class Fish
    attr_reader :fish

    def initialize(string)
      @fish = string.scan(/\d/).each_with_object(Hash.new(0)){|f, h| h[f.to_i] += 1}
    end

    def days(d)
      d.times do
        born = fish[0]
        (0..7).each do |i|
          fish[i] = fish[i+1]
        end
        fish[8] = born
        fish[6] += born
      end
      self
    end

    def count() = fish.values.sum
  end

  EXAMPLE = "3,4,3,1,2"
end
