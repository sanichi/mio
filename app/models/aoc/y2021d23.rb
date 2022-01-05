class Aoc::Y2021d23 < Aoc
  def answer(part)
    burrow = Burrow.new(input)
    Rails.logger.info "XXX #{burrow.room}"
    "not done yet"
  end

  class Burrow
    attr_reader :room, :hall, :cost, :visited
    def initialize(string)
      @room = Array.new(4){[]}
      @hall = Array.new(11)
      @cost = 0
      @visited = false
      string.each_line(chomp:true).each_with_index do |line, i|
        if i == 2 || i == 3
          if line.match(/#+([ABCD])#([ABCD])#([ABCD])#([ABCD])#+/)
            @room[0].push $1.downcase.to_sym
            @room[1].push $2.downcase.to_sym
            @room[2].push $3.downcase.to_sym
            @room[3].push $4.downcase.to_sym
          else
            raise "invalid line #{line}"
          end
        end
      end
      raise "invalid input" unless @room.flatten.sort.join == "aabbccdd"
    end
  end

  EXAMPLE = <<~EOE
    #############
    #...........#
    ###B#C#B#D###
      #A#D#C#A#
      #########
  EOE
end
