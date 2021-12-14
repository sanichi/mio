class Aoc::Y2021d14 < Aoc
  def answer(part)
    Template.new(input).steps(part == 1 ? 10 : 40)
  end

  # credit to Abigail: https://github.com/Abigail/AdventOfCode2021/blob/master/Day_14/solution.pl
  class Template
    attr_reader :pairs, :rules, :start

    def initialize(string)
      @pairs = Hash.new(0)
      @rules = Hash.new{|h,k| h[k] = []}
      string.each_line(chomp: true) do |line|
        if line.match(/\A([A-Z]+)\z/)
          @start = line
          @pairs = (0..line.length-2).each_with_object(Hash.new(0)){|i,h| h[line[i,2]] += 1}
        elsif line.match(/\A([A-Z]{2}) -> ([A-Z])\z/)
          rules[$1] = [$1[0] + $2, $2 + $1[1]]
        else
          raise "invalid line (#{line})" unless line == ""
        end
      end
    end

    def steps(n)
      n.times{step}
      maxmin
    end

    private

    def step
      @pairs = pairs.each_with_object(Hash.new(0)) do |(p,n),h|
        rules[p].each{|q| h[q] += n}
      end
    end

    def maxmin
      count = pairs.each_with_object(Hash.new(0)){|(p,n),h| h[p[0]] += n}
      count[start[-1]] += 1
      counts = count.values
      counts.max - counts.min
    end
  end

  EXAMPLE = <<~EOE
    NNCB

    CH -> B
    HH -> N
    CB -> H
    NH -> C
    HB -> C
    HC -> B
    HN -> C
    NN -> C
    BH -> H
    NC -> B
    NB -> B
    BN -> B
    BB -> N
    BC -> B
    CC -> N
    CN -> C
  EOE
end
