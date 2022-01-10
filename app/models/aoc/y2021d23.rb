class Aoc::Y2021d23 < Aoc
  def answer(part)
    b1 = Burrow.parse(EXAMPLE)
    # b2 = Burrow.parse(TARGET)
    # b3 = Burrow.parse(TARGET)
    # q = MyQueue.new
    # q.push(b1.to_s, 10)
    # q.push(b2.to_s, 100)
    # q.push(b3.to_s, 1000)
    # q.pop
    n1 = b1.room_out(2)
    b2 = Burrow.new(n1[0].first)
    n2 = b2.room_out(1)
    n2.length
  end

  class Burrow
    attr_reader :size, :hall, :room

    COST = {"A" => 1, "B" => 10, "C" => 100, "D" => 1000}
    HLEN = 11

    def initialize(string)
      if string.match(/\A([A-D.]{#{HLEN}})\|(\d+)\|([A-D]{0,4})\|([A-D]{0,4})\|([A-D]{0,4})\|([A-D]{0,4})\z/)
        @hall = $1.split("").map{|x| x == "." ? nil : x}
        @size = $2.to_i
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
      Burrow.new("...........|2|#{room[0].join}|#{room[1].join}|#{room[2].join}|#{room[3].join}")
    end

    def to_s = "#{hall.map{|a| a.nil? ? '.' : a}.join}|#{size}|#{room.map{|r| r.join}.join('|')}"

    def room_out(i)
      raise "invalid room index" unless i >= 0 && i < 4
      return [] if room[i].empty?
      home, start =
        case i
        when 0 then ["A", 2]
        when 1 then ["B", 4]
        when 2 then ["C", 6]
        when 3 then ["D", 8]
        end
      return [] if room[i].all?{|a| a == home}
      left = []
      (0..start-1).to_a.reverse.each do |h|
        if hall[h].nil?
          left.push(h) unless [2,4,6,8].include?(h)
        else
          break
        end
      end
      right = []
      ((start+1)..HLEN-1).each do |h|
        if hall[h].nil?
          right.push(h) unless [2,4,6,8].include?(h)
        else
          break
        end
      end
      return [] if left.empty? && right.empty?
      neighbours = []
      new_room = room[i].dup
      amph = new_room.pop
      up_cost = COST[amph] * (size - room[i].length + 1)
      size_and_rooms = size.to_s + "|" + room.each_with_index.map{|r,j| j == i ? new_room.join : r.join}.join("|")
      left.reverse.each do |l|
        new_hall = hall.dup
        new_hall[l] = amph
        burrow = new_hall.map{|h| h.nil? ? '.' : h}.join + "|" + size_and_rooms
        cost = up_cost + (start - l).abs * COST[amph]
        neighbours.push Burrow.fast_forward(burrow, cost)
      end
      right.each do |r|
        new_hall = hall.dup
        new_hall[r] = amph
        burrow = new_hall.map{|h| h.nil? ? '.' : h}.join + "|" + size_and_rooms
        cost = up_cost + (start - r).abs * COST[amph]
        neighbours.push Burrow.fast_forward(burrow, cost)
      end
      neighbours.each{|n| Rails.logger.info "XXX #{n}"}
      neighbours
    end

    def room_in(i)
      raise "invalid room index" unless i >= 0 && i < 4
      amph, start =
        case i
        when 0 then ["A", 2]
        when 1 then ["B", 4]
        when 2 then ["C", 6]
        when 3 then ["D", 8]
        end
      return [] unless room[i].empty? || (room[i].length < size && room[i].all?{|a| a == amph})
      found = nil
      if found.nil?
        (0..start-1).to_a.reverse.each do |h|
          if !hall[h].nil?
            found = h if hall[h] == amph
            break
          end
        end
      end
      if found.nil?
        ((start+1)..HLEN-1).each do |h|
          if !hall[h].nil?
            found = h if hall[h] == amph
            break
          end
        end
      end
      return unless found
      new_room = room[i] + [amph]
      size_and_rooms = size.to_s + "|" + room.each_with_index.map{|r,j| j == i ? new_room.join : r.join}.join("|")
      new_hall = hall.dup
      new_hall[found] = nil
      burrow = new_hall.map{|h| h.nil? ? '.' : h}.join + "|" + size_and_rooms
      cost = COST[amph] * (size - room[i].length + (start - found).abs)
      [burrow, cost]
    end

    def self.fast_forward(string, cost)
      burrow = self.new(string)
      new_string = extra = nil
      (0..3).each do |i|
        new_string, extra = burrow.room_in(i)
        break if new_string
      end
      if new_string
        fast_forward(new_string, cost + extra)
      else
        [string, cost]
      end
    end
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
