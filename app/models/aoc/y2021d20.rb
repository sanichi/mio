class Aoc::Y2021d20 < Aoc
  def answer(part)
    image = Image.parse(input)
    if part == 1
      image.enhance.enhance.count
    else
      "not done yet"
    end
  end

  class Image
    attr_reader :image, :default, :r0, :rlen, :c0, :clen

    NEIGHBOURS = [[-1,-1],[0,-1],[1,-1],[-1,0],[0,0],[1,0],[-1,1],[0,1],[1,1]]

    def initialize(image, default, r0, rlen, c0, clen)
      @image = image
      @default = default
      @r0 = r0
      @c0 = c0
      @rlen = rlen
      @clen = clen
    end

    def self.parse(string)
      default = "0"
      r0 = c0 = row = 0
      image = rlen = clen = nil
      string.each_line(chomp: true) do |line|
        if line.match?(/\A[.#]+\z/)
          if !image
            @@lookup = line.split("").map{|d| d == "#" ? "1" : "0"}
            image = Hash.new(default)
          else
            line.split("").each_with_index do |d,col|
              image[[col,row]] = d == "#" ? "1" : "0"
              clen = col + 1 if clen.nil? || clen <= col
            end
            row += 1
            rlen = row
          end
        end
      end
      self.new(image, default, r0, rlen, c0, clen)
    end

    def enhance
      _default = default == "0" ? @@lookup.first : @@lookup.last
      _image = Hash.new(_default)
      _r0 = r0 - 1
      _c0 = c0 - 1
      _rlen = rlen + 2
      _clen = clen + 2
      (_r0.._rlen-1).each do |r|
        (_c0.._clen-1).each do |c|
          index = NEIGHBOURS.map{|dc,dr| image[[c+dc,r+dr]]}.join("").to_i(2)
          _image[[c,r]] = @@lookup[index]
        end
      end
      Image.new(_image, _default, _r0, _rlen, _c0, _clen)
    end

    def count = image.values.filter{|d| d == "1"}.count

    def info(tag)
      Rails.logger.info tag
      (r0..rlen-1).each do |r|
        Rails.logger.info (c0..clen-1).map{|c| image[[c,r]] == "1" ? "#" : "."}.join
      end
    end
  end


  EXAMPLE = <<~EOE
    ..#.#..#####.#.#.#.###.##.....###.##.#..###.####..#####..#....#..#..##..###..######.###...####..#..#####..##..#.#####...##.#.#..#.##..#.#......#.###.######.###.####...#.##.##..#..#..#####.....#.#....###..#.##......#.....#..#..#..##..#...##.######.####.####.#.#...#.......#..#.#.#...####.##.#......#..#...##.#.##..#...##.#.##..###.#......#.#.......#.#.#.####.###.##...#.....####.#..#..#.##.#....##..#.####....##...##..#...#......#.#.......#.......##..####..#...#.#.#...##..#.#..###..#####........#..####......#..#

    #..#.
    #....
    ##..#
    ..#..
    ..###
  EOE
end
