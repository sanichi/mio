class Aoc::Y2021d4 < Aoc
  def answer(part)
    game = parse(input)
    if part == 1
      game.play
    else
      game.let_squid_win.play
    end
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
        board = Board.new(game) unless board
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

    def mark(n)
      if number == n
        self.marked = true
        if row.full? || row.board.full_col?(col)
          row.board.won = true
          if row.board.game.over?
            throw :bingo, row.board.sum * n
          end
        end
      end
    end
  end

  class Row
    attr_accessor :numbers, :board

    def initialize(string, board)
      @numbers = string.scan(/\d+/).map(&:to_i).each_with_index.map do |n,c|
        Number.new(n, self, c)
      end
      @board = board
    end

    def mark(n) = numbers.each{|number| number.mark(n)}
    def sum()   = numbers.reduce(0){|s, n| s + (n.marked ? 0 : n.number)}
    def full?() = numbers.all?{|n| n.marked}
  end

  class Board
    attr_accessor :rows, :game, :won

    def initialize(game)
      @game = game
      @rows = []
      @won = false
    end

    def add(string)  = rows.push(Row.new(string, self))
    def mark(n)      = rows.each{|row| row.mark(n)}
    def sum()        = rows.reduce(0){|s,r| s + r.sum}
    def full_col?(c) = rows.map{|r| r.numbers[c].marked}.all?
  end

  class Game
    attr_accessor :draw, :boards

    def initialize(string)
      @draw = string.scan(/\d+/).map(&:to_i)
      @boards = []
      @normal = true
    end

    def play
      catch(:bingo) do
        draw.each do |n|
          boards.each do |b|
            b.mark(n) unless b.won
          end
        end
        0
      end
    end

    def let_squid_win
      @normal = false
      self
    end

    def over?
      @normal || boards.map(&:won).all?
    end

    def add(board) = boards.push(board)
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
