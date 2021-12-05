class Aoc::Y2021d4 < Aoc
  def answer(part)
    game = parse(input)
    part == 1 ? game.play : "not done yet"
  end

  def parse(string)
    game = nil
    board = nil
    string.each_line do |line|
      line.strip!
      case line
      when /\A\d+(,\d+)*\z/
        game = Game.new(line)
      when /\A\d+(\s+\d+)*\z/
        board = Board.new unless board
        board.add(line)
      when ""
        game.add(board) if game && board
        board = nil
      else
        raise "can't parse line [#{line}]"
      end
    end
    raise "couldn't parse input" unless game
    game.add(board) if board
    game.okay!
    game
  end

  class Number
    attr_accessor :number, :marked, :row, :col

    def initialize(int, row, col)
      @number = int
      @row = row
      @col = col
      @marked = false
    end

    def to_s
      number.to_s + (marked ? '*' : '')
    end

    def mark(n)
      if number == n
        self.marked = true
        throw :bingo, [row.board, n] if row.full? || row.board.full_column?(col)
      end
    end
  end

  class Row
    attr_accessor :numbers, :board

    def initialize(string, board)
      @numbers = string.scan(/\d+/).map(&:to_i).each_with_index.map{|n,c| Number.new(n, self, c)}
      raise "row (#{self.to_s}) does not have 5 numbers" unless @numbers.size == 5
      @board = board
    end

    def to_s
      numbers.map(&:to_s).join(" ")
    end

    def mark(n)
      numbers.each{|number| number.mark(n)}
    end

    def sum
      numbers.reduce(0){|s, n| s + (n.marked ? 0 : n.number)}
    end

    def full?
      numbers.all?{|n| n.marked}
    end
  end

  class Board
    attr_accessor :rows

    def initialize
      @rows = []
    end

    def add(string)
      rows.push Row.new(string, self)
    end

    def to_s
      rows.map(&:to_s).join("|")
    end

    def okay!
      raise "board must have 5 rows" unless rows.size == 5
    end

    def mark(n)
      rows.each{|row| row.mark(n)}
    end

    def sum
      rows.reduce(0){|s,r| s + r.sum}
    end

    def full_column?(c)
      rows.map{|r| r.numbers[c].marked}.all?
    end
  end

  class Draw
    attr_accessor :numbers, :index, :max

    def initialize(string)
      @numbers = string.scan(/\d+/).map(&:to_i)
      @index = 0
      @max = @numbers.size
    end

    def to_s
      numbers.each_with_index.map do |n, i|
        n.to_s + (i == index ? '*' : '')
      end.join(",")
    end

    def okay!
      raise "draw must have at least 5 numbers" unless @numbers.size >= 5
    end
  end

  class Game
    attr_accessor :draw, :boards

    def initialize(string)
      @draw = Draw.new(string)
      @boards = []
    end

    def add(board)
      boards.push board
    end

    def to_s
      draw.to_s + "||" + boards.map(&:to_s).join("||")
    end

    def okay!
      raise "game must have a draw" unless draw.present?
      draw.okay!
      raise "game must have at least 1 board" if boards.empty?
      boards.each{|b| b.okay!}
    end

    def play
      board, num = catch(:bingo) {
        draw.numbers.each do |n|
          boards.each do |b|
            b.mark(n)
          end
        end
        []
      }
      return 0 unless board && num
      board.sum * num
    end
  end

  EXAMPLE = <<-EOE
    7,4,9,5,11,17,23,2,0,14,21,24,10,16,13,6,15,25,12,22,18,20,8,19,3,26,1

    22 13 17 11  0
     8  2 23  4 24
    21  9 14 16  7
     6 10  3 18  5
     1 12 20 15 19

     3 15  0  2 22
     9 18 13 17  5
    19  8  7 25 23
    20 11 10 24  4
    14 21 16 12  6

    14 21 17 24  4
    10 16 15  9 19
    18  8 23 26 20
    22 11 13  6  5
     2  0 12  3  7
  EOE
end
