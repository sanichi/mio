class Aoc::Y2021d24 < Aoc
  def answer(part) = Alu.new(input).send(part == 1 ? :highest : :lowest)

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

    def lowest
      monad = []
      # w3=w2-7
      monad[2] = 8
      monad[3] = 1
      # w5=w4+1
      monad[4] = 1
      monad[5] = 2
      # w8=w7+5
      monad[7] = 1
      monad[8] = 6
      # w10=w9
      monad[9] = 1
      monad[10] = 1
      # w11=w6+8
      monad[6] = 1
      monad[11] = 9
      # w12=w1+7
      monad[12] = 8
      monad[1] = 1
      # w13=w0-8
      monad[0] = 9
      monad[13] = 1
      monad = monad.map(&:to_s).join
      check("lowest", monad)
      monad
    end

    def highest
      monad = []
      # w3=w2-7
      monad[2] = 9
      monad[3] = 2
      # w5=w4+1
      monad[4] = 8
      monad[5] = 9
      # w8=w7+5
      monad[7] = 4
      monad[8] = 9
      # w10=w9
      monad[9] = 9
      monad[10] = 9
      # w11=w6+8
      monad[6] = 1
      monad[11] = 9
      # w12=w1+7
      monad[12] = 9
      monad[1] = 2
      # w13=w0-8
      monad[0] = 9
      monad[13] = 1
      monad = monad.map(&:to_s).join
      check("higest", monad)
      monad
    end

    def process(input)
      inputs = input.split("").map(&:to_i)
      instructions.each_with_index do |i,j|
        _a2 = i.a2.is_a?(Integer) ? i.a2 : v[i.a2] unless i.a2.nil?
        case i.op
        when :inp
          raise "input exhausted" if inputs.empty?
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
      v[:z]
    end

    def equivalent_process(input)
      inputs = input.split("").map(&:to_i)
      [
        [1,12,4],    # 0  w0+4
        [1,15,11],   # 1  w0+4,w1+11
        [1,11,7],    # 2  w0+4,w1+11,w2+7
        [26,-14,2],  # 3  w0+4,w1+11              w2+7=w3+14  => w3=w2-7
        [1,12,11],   # 4  w0+4,w1+11,w4+11
        [26,-10,13], # 5  w0+4,w1+11              w4+11=w5+10 => w5=w4+1
        [1,11,9],    # 6  w0+4,w1+11,w6+9
        [1,13,12],   # 7  w0+4,w1+11,w6+9,w7+12
        [26,-7,6],   # 8  w0+4,w1+11,w6+9         w7+12=w8+7  => w8=w7+5
        [1,10,2],    # 9  w0+4,w1+11,w6+9,w9+2
        [26,-2,11],  # 10 w0+4,w1+11,w6+9         w9+2=w10+2  => w10=w9
        [26,-1,12],  # 11 w0+4,w1+11              w6+9=w11+1  => w11=w6+8
        [26,-4,3],   # 12 w0+4                    w1+11=w12+4 => w12=w1+7
        [26,-12,13], # 13                         w0+4=w13+12 => w13=w0-8
      ].each_with_index do |(q,a,b),j|
        raise "input exhausted" if inputs.empty?
        v[:w] = inputs.shift
        v[:x] = (v[:z].modulo(26) + a != v[:w]) ? 1 : 0
        v[:z] = v[:z] / q
        if v[:x] == 1
          v[:y] = b + v[:w]
          v[:z] = v[:z] * 26 + v[:y]
        else
          v[:y] = 0
        end
      end
      v[:z]
    end

    def check(version, monad)
      raise "#{version} ALU error" unless process(monad) == 0
      raise "#{version} EQU error" unless equivalent_process(monad) == 0
    end
  end

  class Instruction
    attr_reader :op, :a1, :a2

    def initialize(op, a1, a2=nil)
      @op = op.to_sym
      @a1 = a1.to_sym
      @a2 = a2.nil? ? nil : (a2.match?(/[wxyz]/) ? a2.to_sym : a2.to_i)
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

# From JulienTT on reddit
#
# As many others pointed out, the input is a sequence of 14 instructions, which take as input "w" (the entry)
# and update a number "z", which starts at zero. This can be formalized as
#
# z(t+1)=f(z(t),w,q,n1,n2)
#
# There are seven calls with q=1 and seven with q=26. I detail them separately.
#
# For q=1:
#
# f(z,w,q=1,n1,n2)=z if z%26=w-n1.
#
# f(z,w,q=1,n1,n2)=26z+w-n2 if z%26!=w-n1.
#
# Direct inspection of the input show that, for 0<w<10, w-n1 is always negative: the function is always
# called using the second case. To understand what this formula does, it is best to represent the value
# of z in basis 26:
#
# z=abc means z=c+b*26+a*26*26
#
# f(z)=26z+w-n2 thus adds one "character" to the right of "z", this character being equal to w-n2, which is always smaller than 26.
#
# For q=2:
#
# f(z,w,q=26,n1,n2)=z//26 if z%26=w-n1.
#
# f(z,w,q=26,n1,n2)=26(z//26)+w-n2 if z%26!=w-n1,
#
# where I have used python notation // for integer division. The first case simply deletes the last
# character of z in basis 26. The second line replaces it by w-n2, hence keeping its lenght intact.
#
# In principle, this function is problematic since the second case associate 25 values of z to one
# value of the ouput (for instance, 0//26=1//26=...=25//26=0). What saves us here is that the seven
# times the function is called with q=1 will increase the length of z by a total of seven. The seven
# calls of f with q=2 thus have to decrease the length of z if we want to get back to zero.
#
# But this only happens if the last character of the string representing z is equal to w-n1 when
# the function is called.The seven calls of the function with q=26 thus lead to seven constraints
# between the digits of the input.
#
# Let us look at the beginning of my input, starting from z=0.
#
# z=f1(z,w1,1,10,13) -> z="w1+13"
#
# z=f1(z,w2,1,13,10) -> z="w1+13" . "w2+10"
#
# z=f1(z,w3,1,13,3) -> z="w1+13" . "w2+10" . "w3+3"
#
# z=f2(z,w4,26,-11,1) -> z="w1+13" . "w2+10"
#
# For this fourth call to give an acceptable solution, we need that the rightest character in z before
# the call, "w3+3", be equal to "w4-n1=w4+11". We thus get a first contraint:
#
# w3=w4+8.
#
# At the end of all instructions, we will get seven constraints between pairs of inputs. To get the
# largest entry w1w2w3w4w5w6w7w8w9w10w11w12w13w14 that solves the problem, we simply choose the largest
# [values for the w‘s that satisfy the corresponding constraints. For part 2 we choose the smallest].