class Aoc::Y2021d16 < Aoc
  def answer(part) = parse(input).send(part == 1 ? :versions : :compute)

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
      packet =
        if type == 4
          value = ""
          loop do
            group = remainder[i+=l,l=5]
            value += group[1,4]
            break if group[0] == "0"
          end
          Value.new(version, type, i+=l, value.to_i(2))
        else
          len_type = remainder[i+=l,l=1]
          if len_type == "0"
            sub_len = remainder[i+=l,l=15].to_i(2)
            LengthOperator.new(version, type, i+=l, sub_len)
          else
            sub_num = remainder[i+=l,l=11].to_i(2)
            NumberOperator.new(version, type, i+=l, sub_num)
          end
        end
      remainder = remainder[i..-1]

      while packet.full? && !stack.empty? && !stack.last.full?
        operator = stack.pop
        operator.add(packet)
        packet = operator
      end

      stack.push packet
    end

    raise "failed" unless stack.length == 1

    stack.pop
  end

  class Packet
    attr_reader :version, :type, :len, :args

    def initialize(version, type, len)
      @version = version
      @type = type
      @len = len
      @args = []
    end

    def add(arg)
      @args.push arg
      @len += arg.len
    end

    def versions
      version + args.map(&:versions).sum
    end

    def compute
      if type == 4
        value
      else
        values = args.map(&:compute)
        case type
        when 0
          values.sum
        when 1
          values.reduce(1){|p,v| p * v}
        when 2
          values.min
        when 3
          values.max
        when 5
          values[0] > values[1] ? 1 : 0
        when 6
          values[0] < values[1] ? 1 : 0
        when 7
          values[0] == values[1] ? 1 : 0
        else
          raise "invalid type"
        end
      end
    end
  end

  class Value < Packet
    attr_reader :value

    def initialize(version, type, len, value)
      super(version, type, len)
      @value = value
    end

    def full?() = true
  end

  class LengthOperator < Packet
    attr_reader :sub_len

    def initialize(version, type, len, sub_len)
      super(version, type, len)
      @sub_len = sub_len
    end

    def full? = sub_len == args.map(&:len).sum
  end

  class NumberOperator < Packet
    attr_reader :sub_num

    def initialize(version, type, len, sub_num)
      super(version, type, len)
      @sub_num = sub_num
    end

    def full? = sub_num == args.length
  end

  EXAMPLES = [
    "D2FE28",
    "38006F45291200",
    "EE00D40C823060",
    "8A004A801A8002F478",
    "620080001611562C8802118E34",
    "C0015000016115A2E0802F182340",
    "A0016C880162017C3686B18A3D4780",
    "C200B40A82",
    "04005AC33890",
    "880086C3E88112",
    "CE00C43D881120",
    "D8005AC2A8F0",
    "F600BC2D8F",
    "9C005AC2F8F0",
    "9C0141080250320F1802104A08",
  ]
end
