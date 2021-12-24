class Aoc::Y2021d21 < Aoc
  def answer(part)
    game = Game.new(input)
    if part == 1
      game.deterministic
    else
      "not done yet"
    end
  end

  class Game
    attr_reader :player1, :player2, :score1, :score2, :die, :rolls

    def initialize(string)
      if string.match(/Player 1\D+([1-9]|10)\D+Player 2\D+([1-9]|10)/)
        @player1 = $1.to_i
        @player2 = $2.to_i
        @score1 = 0
        @score2 = 0
        @die = 100
        @rolls = 0
      else
        raise "invalid input"
      end
    end

    def deterministic(turn1=true)
      move = roll + roll + roll
      if turn1
        @player1 = (player1 - 1 + move).modulo(10) + 1
        @score1 += player1
        if score1 < 1000
          deterministic(false)
        else
          score2 * rolls
        end
      else
        @player2 = (player2 - 1 + move).modulo(10) + 1
        @score2 += player2
        if score2 < 1000
          deterministic(true)
        else
          score1 * rolls
        end
      end
    end

    private

    def roll
      @die += 1
      @die = 1 if @die > 100
      @rolls += 1
      @die
    end
  end

  EXAMPLE = <<~EOE
    Player 1 starting position: 4
    Player 2 starting position: 8
  EOE
end
