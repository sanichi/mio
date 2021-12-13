class Aoc::Y2021d13 < Aoc
  def answer(part)
    paper = Paper.new(input)
    if part == 1
      paper.fold_first
    else
      paper.fold_all
    end
  end

  class Paper
    attr_reader :dots, :instructions, :width, :height

    def initialize(string)
      @dots = {}
      @instructions = []
      @width = nil
      @height = nil
      string.each_line(chomp: true) do |line|
        if line.match(/\A(\d+),(\d+)\z/)
          x = $1.to_i
          y = $2.to_i
          @dots[[x,y]] = true
        elsif line.match(/\Afold along (x|y)=(\d+)/)
          s = $2.to_i
          if $1 == "x"
            @instructions.push s
            @width = 2 * s + 1 unless @width
          else
            @instructions.push -s
            @height = 2 * s + 1 unless @height
          end
        else
          raise "invalid line" unless line == ""
        end
      end
    end

    def fold_first
      fold(instructions.first)
      dots.values.select{|v| v}.size
    end

    def fold_all
      instructions.each{|i| fold(i)}
      (0..height-1).each do |y|
        Rails.logger.info (0..width-1).map{|x| dots[[x,y]] ? "#" : '.'}.join
      end
      "EPZGKCHU" # from visual inspection of log output
    end

    private

    def fold(i)
      i > 0 ? fold_left(i) : fold_up(i.abs)
    end

    def fold_left(x)
      @width = x
      dots.keys.each do |i,j|
        if i > width
          dots[[2 * width - i,j]] = true
          dots.delete [i,j]
        end
      end
    end

    def fold_up(y)
      @height = y
      dots.keys.each do |i,j|
        if j > height
          dots[[i, 2 * height - j]] = true
          dots.delete [i,j]
        end
      end
    end
  end

  EXAMPLE = <<~EOE
    6,10
    0,14
    9,10
    0,3
    10,4
    4,11
    6,0
    6,12
    4,1
    0,13
    10,12
    3,4
    3,0
    8,4
    1,10
    2,14
    8,10
    9,0

    fold along y=7
    fold along x=5
  EOE
end
