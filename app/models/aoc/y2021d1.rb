class Aoc::Y2021d1 < Aoc
  def answer(part)
    part == 1 ? sweeps(depths) : sliders(depths)
  end

  def sweeps(list)
    count = 0
    index = 0
    while list.size - index >= 2
      count += 1 if list[index] < list[index + 1]
      index += 1
    end
    count
  end

  def sliders(list)
    count = 0
    index = 0
    s1 = list[0, 3].sum
    while list.size - index >= 4
      index += 1
      s2 = list[index, 3].sum
      count += 1 if s1 < s2
      s1 = s2
    end
    count
  end

  def depths
    input.scan(/\d+/).map(&:to_i)
  end

  def initialize(input)
    super
  end

  EXAMPLE = <<-EOE
199
200
208
210
200
207
240
269
260
263
EOE
end
