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

# Part 1 I solved by inspection, I guessed the optimal solution without a computer and it worked!
# For Part 2 I used Dijkstra + heapq to find the shortest distance through a huge graph, probably
# what many did. I kept the intermediate states as strings for easy debugging. For transitions
# we only need to worry about moves out of the home rooms, then after each move anything that
# can go home does so, without an intermediate graph node. Fun one!
