class Aoc::Y2021d16 < Aoc
  def answer(part)
    parse(EXAMPLE[4]).to_s
    "not done yet"
  end

  def parse(string)
    remainder = string.scan(/[0-9A-F]/).map do |d|
      case d
      when "0" then "0000"
      when "1" then "0001"
      when "2" then "0010"
      when "3" then "0011"
      when "4" then "0100"
      when "5" then "0101"
      when "6" then "0110"
      when "7" then "0111"
      when "8" then "1000"
      when "9" then "1001"
      when "A" then "1010"
      when "B" then "1011"
      when "C" then "1100"
      when "D" then "1101"
      when "E" then "1110"
      when "F" then "1111"
      else ""
      end
    end.join

    stack = []

    while !remainder.match?(/\A0*\z/) do
      i = 0
      l = 0
      version = remainder[i+=l,l=3].to_i(2)
      type = remainder[i+=l,l=3].to_i(2)
      len = 6
      packet =
        if type == 4
          val = ""
          loop do
            group = remainder[i+=l,l=5]
            val += group[1,4]
            len += 5
            break if group[0] == "0"
          end
          value = val.to_i(2)
          Value.new(version, type, len, value)
        else
          len_type = remainder[i+=l,l=1]
          len += 1
          if len_type == "0"
            sub_len = remainder[i+=l,l=15].to_i(2)
            LengthOperator.new(version, type, len, sub_len)
          else
            sub_num = remainder[i+=l,l=11].to_i(2)
            NumberOperator.new(version, type, len, sub_num)
          end
        end

      len = i + l
      stack.push packet

      remainder = remainder[len..-1]
    end


    loop do
      arguments = []
      while stack.last&.full? do
        arguments.unshift(stack.pop)
      end
      if arguments.empty?
        break
      elsif stack.empty?
        stack = arguments
        break
      else
        arguments.each{|a| stack[-1].add(a)}
      end
    end

    stack.map(&:to_s).join(" ")
  end

  Packet1 = Struct.new(:version, :type, :len, :value, :len_type, :sub_len, :sub_num, :children) do
    def is_operator?
      type != 4
    end

    def is_value?
      type == 4
    end

    def add(packet)
      return false if is_value?
      if sub_len
        if children.map(&:len).sum + packet.len > sub_len
          return false
        else
          children.push packet
          return true
        end
      else
        if children.size >= sub_num
          return false
        else
          children.push packet
          return true
        end
      end
    end

    def to_s
      sprogs = "[" + children.map(&:to_s).join(",") + "]"
      if is_value?
        ["V", version, type, len, value].join("|")
      elsif len_type == "0"
        ["L", version, type, len, sub_len, sprogs].join("|")
      else
        ["N", version, type, len, sub_num, sprogs].join("|")
      end
    end
  end

  class Packet
    attr_reader :version, :type, :len

    def initialize(version, type, len)
      @version = version
      @type = type
      @len = len
    end
  end

  class Value < Packet
    attr_reader :version, :type, :value

    def initialize(version, type, len, value)
      super(version, type, len)
      @value = value
    end

    def value?() = true
    def full?() = true

    def to_s
      ["V", version, type, len, value].join(":")
    end
  end

  class LengthOperator < Packet
    attr_reader :version, :type, :len, :sub_len, :args

    def initialize(version, type, len, sub_len)
      super(version, type, len)
      @sub_len = sub_len
      @args = []
    end

    def add(arg)
      @args.push arg
      @len += arg.len
    end

    def value?() = false
    def full? = sub_len == args.map(&:len).sum

    def to_s
      f = full? ? 't' : 'f'
      ["L", version, type, len, sub_len, f, "#{args.map(&:to_s).join(',')})"].join(":")
    end
  end

  class NumberOperator < Packet
    attr_reader :version, :type, :len, :sub_num, :args

    def initialize(version, type, len, sub_num)
      super(version, type, len)
      @sub_num = sub_num
      @args = []
    end

    def add(arg)
      @args.push arg
      @len += arg.len
    end

    def value?() = false
    def full? = sub_num == args.length

    def to_s
      f = full? ? 't' : 'f'
      ["N", version, type, len, sub_num, f, "(#{args.map(&:to_s).join(',')})"].join(":")
    end
  end

  EXAMPLE = [
    "D2FE28",
    "38006F45291200",
    "EE00D40C823060",
    "8A004A801A8002F478",
    "620080001611562C8802118E34",
    "C0015000016115A2E0802F182340",
    "A0016C880162017C3686B18A3D4780",
  ]
end
