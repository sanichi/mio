class Aoc::Y2021d24 < Aoc
  def answer(part)
    alu = Alu.new(input)
    if part == 1
      alu.process(11111111111111)
      alu.procezz(11111111111111)
      "not done yet"
    else
      "not done yet"
    end
  end

  class Alu
    attr_reader :instructions, :v

    def initialize(string)
      @v = {w: 0, x: 0, y: 0, z: 0}
      @instructions = []
      string.each_line(chomp: true) do |line|
        case line
        when /(inp) (w|x|y|z)/
          instructions.push Instruction.new($1, $2)
        when /(add|mul|div|mod|eql) (w|x|y|z) (w|x|y|z|-?\d+)/
          instructions.push Instruction.new($1, $2, $3)
        else
          raise "invalid input (#{line})"
        end
      end
    end

    def reset = [:w, :x, :y, :z].each{|r| v[r] = 0}

    def process(input)
      inputs = input.to_s.split("").map(&:to_i)
      reset
      instructions.each_with_index do |i,j|
        _a2 = i.a2.is_a?(Integer) ? i.a2 : v[i.a2] unless i.a2.nil?
        case i.op
        when :inp
          raise "input exhausted" if inputs.empty?
          Rails.logger.info "XXX #{1 + j/18} #{self}"
          v[i.a1] = inputs.shift
        when :add
          v[i.a1] += _a2
        when :mul
          v[i.a1] *= _a2
        when :div
          raise "zero denominator in division" if _a2 == 0
          v[i.a1] = (v[i.a1].to_f / _a2).truncate
        when :mod
          raise "zero denominator in modulo" if _a2 == 0
          v[i.a1] = v[i.a1].modulo(_a2)
        when :eql
          v[i.a1] = v[i.a1] == _a2 ? 1 : 0
        else
          raise "illegal instruction #{i}"
        end
      end
      Rails.logger.info "XXX ff #{self}"
      v[:z]
    end

    def procezz(input)
      inputs = input.to_s.split("").map(&:to_i)
      reset
      [
        [1,12,4],
        [1,15,11],
        [1,11,7],
        [26,-14,2],
        [1,12,11],
        [26,-10,13],
        [1,11,9],
        [1,13,12],
        [26,-7,6],
        [1,10,2],
        [26,-2,11],
        [26,-1,12],
        [26,-4,3],
        [26,-12,13],
      ].each_with_index do |(q,a,b),j|
        raise "input exhausted" if inputs.empty?
        Rails.logger.info "YYY #{j+1} #{self}"
        v[:w] = inputs.shift
        v[:x] = (v[:z].modulo(26) + a != v[:w]) ? 1 : 0
        v[:z] = v[:z].truncate(q)
        if v[:x] == 1
          v[:y] = b + v[:w]
          v[:z] = v[:z] * 26
          v[:z] = v[:z] + v[:y]
        else
          v[:y] = 0
        end
      end
      Rails.logger.info "YYY ff #{self}"
      v[:z]
    end

    def largest_monad
      monad = 11111111111111
      while monad < 11111111311111
        monad += 1
        monad_ = monad.to_s
        next if monad_.match?("0")
        process(monad_.split("").map(&:to_i))
        Rails.logger.info "XXX #{monad} #{self}" if v[:z] == 0
        return monad if v[:z] == 0
      end
      "monad not found"
    end

    def to_s(full=false)
      vars = "#{v[:w]},#{v[:x]},#{v[:y]},#{v[:z]}"
      return vars unless full
      "#{vars} #{instructions.map(&:to_s).join('|')}"
    end
  end

  class Instruction
    attr_reader :op, :a1, :a2

    def initialize(op, a1, a2=nil)
      @op = op.to_sym
      @a1 = a1.to_sym
      @a2 = a2.nil? ? nil : (a2.match?(/[wxyz]/) ? a2.to_sym : a2.to_i)
    end

    def to_s
      "#{op} #{a1}#{a2.nil? ? '' : ' '}#{a2}"
    end
  end

  EXAMPLE = <<~EOE
    inp w
    add z w
    mod z 2
    div w 2
    add y w
    mod y 2
    div w 2
    add x w
    mod x 2
    div w 2
    mod w 2
  EOE
end
