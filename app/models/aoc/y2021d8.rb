class Aoc::Y2021d8 < Aoc
  def answer(part)
    entries = input.each_line.map{|l| Entry.new(l)}
    if part == 1
      entries.map(&:count).sum
    else
      entries.map(&:decode).sum
    end
  end

  class Entry
    attr_reader :patterns, :digits

    def initialize(string)
      words = string.scan(/[a-g]+/)
      raise "invalid input" unless words.length == 14
      @patterns = words.first(10).map{|p| p.split("").to_set}
      @digits = words.last(4).map{|d| d.split("")}
    end

    def count
      digits.filter{|s| [2,3,4,7].include?(s.size)}.size
    end

    def decode
      abcdefg = "abcdefg".split("").to_set

      cf = patterns.filter{|p| p.size == 2}.first
      acf = patterns.filter{|p| p.size == 3}.first
      a = acf - cf

      bcdf = patterns.filter{|p| p.size == 4}.first
      bd = bcdf - cf
      abcefg = patterns.filter{|p| p.size == 6 && !bd.subset?(p)}.first
      d = abcdefg - abcefg
      b = bcdf - cf - d

      abcdfg = patterns.filter{|p| p.size == 6 && bd.subset?(p) && cf.subset?(p)}.first
      e = abcdefg - abcdfg
      g = abcdefg - bcdf - a - e

      acdeg = patterns.filter{|p| p.size == 5 && e.subset?(p)}.first
      c = acdeg - a - d - e - g
      f = abcdefg - acdeg - b

      h = [
        [a.to_a.first, "a"],
        [b.to_a.first, "b"],
        [c.to_a.first, "c"],
        [d.to_a.first, "d"],
        [e.to_a.first, "e"],
        [f.to_a.first, "f"],
        [g.to_a.first, "g"],
      ].to_h

      digits.map do |d|
        case d.map{|x| h[x]}.sort.join
        when "abcefg"
          "0"
        when "cf"
          "1"
        when "acdeg"
          "2"
        when "acdfg"
          "3"
        when "bcdf"
          "4"
        when "abdfg"
          "5"
        when "abdefg"
          "6"
        when "acf"
          "7"
        when "abcdefg"
          "8"
        when "abcdfg"
          "9"
        else
          nil
        end
      end.join.to_i
    end
  end

  EXAMPLE = <<~EOE
    be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe
    edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc
    fgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef | cg cg fdcagb cbg
    fbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega | efabcd cedba gadfec cb
    aecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga | gecf egdcabf bgf bfgea
    fgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf | gebdcfa ecba ca fadegcb
    dbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf | cefg dcbef fcge gbcadfe
    bdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd | ed bcgafe cdgba cbgef
    egadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg | gbdfcae bgc cg cgb
    gcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc | fgae cfgab fg bagce
  EOE
end
