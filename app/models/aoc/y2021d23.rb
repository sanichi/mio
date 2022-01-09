class Aoc::Y2021d23 < Aoc
  def answer(part)
    b1 = Burrow.parse(EXAMPLE)
    b2 = Burrow.parse(TARGET)
    b3 = Burrow.parse(TARGET)
    q = MyQueue.new
    q.push(b1.to_s, 10)
    q.push(b2.to_s, 100)
    q.push(b3.to_s, 1000)
    q.pop
  end

  class Burrow
    attr_reader :size, :hall, :room

    def initialize(string)
      if string.match(/\A(\d+)\|([A-D.]{11})\|([A-D]{0,4})\|([A-D]{0,4})\|([A-D]{0,4})\|([A-D]{0,4})\z/)
        @size = $1.to_i
        @hall = $2.split("").map{|x| x == "." ? nil : x}
        @room = []
        @room.push($3.split(""))
        @room.push($4.split(""))
        @room.push($5.split(""))
        @room.push($6.split(""))
        (0..3).each{|i| raise "room #{i} too big" if room[i].length > size}
        raise "invalid amphipods" unless (hall.compact + room.flatten).sort.join == "AABBCCDD"
      else
        raise "invalid constructor string"
      end
    end

    def self.parse(string)
      room = Array.new(4){[]}
      string.each_line(chomp:true).each_with_index do |line, i|
        if i == 2 || i == 3
          if line.match(/#+([ABCD])#([ABCD])#([ABCD])#([ABCD])#+/)
            room[0].unshift $1
            room[1].unshift $2
            room[2].unshift $3
            room[3].unshift $4
          else
            raise "invalid line #{line}"
          end
        end
      end
      raise "room size parse" unless room.all?{|r| r.size == 2}
      Burrow.new("2|...........|#{room[0].join}|#{room[1].join}|#{room[2].join}|#{room[3].join}")
    end

    def to_s = "#{size}|#{hall.map{|a| a.nil? ? '.' : a}.join}|#{room.map{|r| r.join}.join('|')}"
  end

  EXAMPLE = <<~EOE
    #############
    #...........#
    ###B#C#B#D###
      #A#D#C#A#
      #########
  EOE

  TARGET = <<~EOT
    #############
    #...........#
    ###A#B#C#D###
      #A#B#C#D#
      #########
  EOT
end

# Part 1 I solved by inspection, I guessed the optimal solution without a computer and it worked!
# For Part 2 I used Dijkstra + heapq to find the shortest distance through a huge graph, probably
# what many did. I kept the intermediate states as strings for easy debugging. For transitions
# we only need to worry about moves out of the home rooms, then after each move anything that
# can go home does so, without an intermediate graph node. Fun one!

class MyQueue
  attr_reader :que

  def initialize
    @que = []
  end

  def push(v,c)
    reheap(v,c)
  end

  def size = @que.size
  def pop  = @que.pop

  private

  def reheap(v, c)
    if size == 0
      que.push([v,c])
    else
      que.insert(binary_index([v, c]), [v, c])
    end
  end

  def binary_index(target)
    upper = que.size - 1
    lower = 0

    while(upper >= lower) do
      idx  = lower + (upper - lower) / 2

      case target.last <=> que[idx].last
      when 1
        lower = idx + 1
      when -1
        upper = idx - 1
      else
        return idx
      end
    end

    lower
  end
end
