class Aoc::Y2021d10 < Aoc
  def answer(part)
    chunks = input.each_line.map{|s| Chunk.new(s)}
    if part == 1
      chunks.map(&:corrupt).sum
    else
      scores = chunks.map(&:incomplete).select{|s| s > 0}.sort
      scores[scores.length / 2]
    end
  end

  class Chunk
    attr_reader :brackets

    CLOSING = {
      ")" => "(",
      "]" => "[",
      "}" => "{",
      ">" => "<",
    }

    CORRUPT = {
      ")" => 3,
      "]" => 57,
      "}" => 1197,
      ">" => 25137,
    }

    INCOMPLETE = {
      "(" => 1,
      "[" => 2,
      "{" => 3,
      "<" => 4,
    }

    def initialize(string)
      @brackets = string.scan(/[\(\[\{\<\)\]\}\>]/)
    end

    def corrupt
      stack = []
      brackets.each do |b|
        if CLOSING[b]
          if stack.empty?
            return CORRUPT[b]
          else
            if CLOSING[b] == stack.last
              stack.pop
            else
              return CORRUPT[b]
            end
          end
        else
          stack.push(b)
        end
      end
      0
    end

    def incomplete
      stack = []
      brackets.each do |b|
        if CLOSING[b]
          if stack.empty?
            return 0
          else
            if CLOSING[b] == stack.last
              stack.pop
            else
              return 0
            end
          end
        else
          stack.push(b)
        end
      end
      stack.reverse.reduce(0) do |s, b|
        5 * s + INCOMPLETE[b]
      end
    end
  end

  EXAMPLE = <<~EOE
    [({(<(())[]>[[{[]{<()<>>
    [(()[<>])]({[<{<<[]>>(
    {([(<{}[<>[]}>{[]{[(<()>
    (((({<>}<{<{<>}{[]{[]{}
    [[<[([]))<([[{}[[()]]]
    [{[{({}]{}}([{[{{{}}([]
    {<[[]]>}<{[{[{[]{()[[[]
    [<(<(<(<{}))><([]([]()
    <{([([[(<>()){}]>(<<{{
    <{([{{}}[<[[[<>{}]]]>[]]
  EOE
end
