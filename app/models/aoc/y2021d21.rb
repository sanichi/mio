class Aoc::Y2021d21 < Aoc
  def answer(part) = Game.new(input).send(part == 1 ? :deter : :dirac)

  class Game
    attr_reader :player1, :player2

    DETER = 1000
    DIRAC = 21
    MFREQ = {3 => 1, 4 => 3, 5 => 6, 6 => 7, 7 => 6, 8 => 3, 9 => 1}

    def initialize(string)
      if string.match(/Player 1\D+([1-9]|10)\D+Player 2\D+([1-9]|10)/)
        @player1 = $1.to_i
        @player2 = $2.to_i
      else
        raise "invalid input"
      end
    end

    def deter
      @die = 100
      @rolls = 0
      _deter(@player1, @player2, 0, 0, true)
    end

    def dirac
      @p1_wins = 0
      @p2_wins = 0
      MFREQ.keys.each{|move| _dirac(player1, player2, 0, 0, true, move, 1)}
      [@p1_wins, @p2_wins].max
    end

    private

    def add(p,m) = (p - 1 + m).modulo(10) + 1

    def roll
      @die += 1
      @die = 1 if @die > 100
      @rolls += 1
      @die
    end

    def _deter(p1, p2, s1, s2, turn1)
      move = roll + roll + roll
      if turn1
        p1 = add(p1, move)
        s1 += p1
        if s1 >= DETER
          s2 * @rolls
        else
          _deter(p1, p2, s1, s2, false)
        end
      else
        p2 = add(p2, move)
        s2 += p2
        if s2 >= DETER
          s1 * @rolls
        else
          _deter(p1, p2, s1, s2, true)
        end
      end
    end

    def _dirac(p1, p2, s1, s2, turn1, move, freq)
      freq *= MFREQ[move]
      if turn1
        p1 = add(p1, move)
        s1 += p1
        if s1 >= DIRAC
          @p1_wins += freq
        else
          MFREQ.keys.each{|move| _dirac(p1, p2, s1, s2, false, move, freq)}
        end
      else
        p2 = add(p2, move)
        s2 += p2
        if s2 >= DIRAC
          @p2_wins += freq
        else
          MFREQ.keys.each{|move| _dirac(p1, p2, s1, s2, true, move, freq)}
        end
      end
    end
  end

  EXAMPLE = <<~EOE
    Player 1 starting position: 4
    Player 2 starting position: 8
  EOE
end
