class Aoc::Y2021d19 < Aoc
  def answer(part)
    scans = parse(EXAMPLE)
    if part == 1
      diff = scans.first.diffs
      set = diff.set
      scans.each_with_index do |scan, i|
        ROTATE.each do |r|
          rdiff = scan.rotate(r).diffs
          cap = set.intersection(rdiff.set)
          Rails.logger.info "XXX #{i} #{r} #{cap.size}" if cap.size > 0
        end
      end
      "here"
    else
      Rails.logger.info "XXX #{scans.first.diffs}"
      "not done yet"
    end
  end

  ROTATE = [
    [ 1,  2,  3],
    [ 1,  3, -2],
    [ 1, -2, -3],
    [ 1, -3,  2],
    [-1,  2, -3],
    [-1,  3,  2],
    [-1, -2,  3],
    [-1, -3, -2],
    [ 2,  3,  1],
    [ 2,  1, -3],
    [ 2, -3, -1],
    [ 2, -1,  3],
    [-2,  1,  3],
    [-2,  3, -1],
    [-2, -1, -3],
    [-2, -3,  1],
    [ 3,  1,  2],
    [ 3, -2,  1],
    [ 3, -1, -2],
    [ 3,  2, -1],
    [-3,  2,  1],
    [-3,  1, -2],
    [-3, -2, -1],
    [-3, -1,  2],
  ]

  def parse(string)
    scans = []
    scan = nil
    string.each_line(chomp: true) do |line|
      case line
      when /\A--- scanner (\d+) ---\z/
        raise "invalid header" if scan
        scan = Scan.new
      when /\A(-?\d+),(-?\d+),(-?\d+)\z/
        raise "invalid point" unless scan
        scan.add($1, $2, $3)
      when ""
        raise "invalid spacer" unless scan
        scans.push scan
        scan = nil
      else
        raise "invalid input"
      end
    end
    scans.push scan if scan
    scans.reverse
  end

  class Scan
    attr_reader :points

    def initialize
      @points = []
    end

    def diffs
      points.combination(2).each_with_object(Diffs.new){|(p,q),d| d.add(p,q)}
    end

    def add(x, y, z) = points.push(Point.new(x, y, z))
    def rotate(r)    = points.each_with_object(Scan.new){|p, s| s.add(*(p.rotate(r).to_a))}
    def to_s         = points.map(&:to_s).join(",")
  end

  class Diffs
    attr_reader :diffs

    def initialize
      @diffs = Hash.new{|h,k| h[k] = []}
    end

    def add(p, q)
      dx = q.x - p.x
      dy = q.y - p.y
      dz = q.z - p.z
      if dx > 0 || (dx == 0 && dy > 0) || (dx == 0 && dy == 0 && dz >= 0)
        diffs[[dx,dy,dz]].push(p)
      else
        diffs[[-dx,-dy,-dz]].push(q)
      end
    end

    def set
      @set ||= diffs.keys.to_set
    end

    def to_s
      diffs.keys.map{|d| "#{d} => #{diffs[d].join(', ')}"}.join("|")
    end
  end

  class Point
    attr_reader :x, :y, :z

    def initialize(x, y, z)
      @x = x.to_i
      @y = y.to_i
      @z = z.to_i
    end

    def rotate(r)
      cmp = Array.new(3)
      r.each_with_index do |to, i|
        case to
        when 1
          cmp[i] = x
        when -1
          cmp[i] = -x
        when 2
          cmp[i] = y
        when -2
          cmp[i] = -y
        when 3
          cmp[i] = z
        when -3
          cmp[i] = -z
        else
          raise "invalid rotate"
        end
      end
      Point.new(*cmp)
    end

    def ==(o)   = [x,y,z] == [o.x,o.y,o.z]
    def eql?(o) = self == o
    def hash    = [x,y,z].hash
    def to_s    = "(#{x},#{y},#{z})"
    def to_a    = [x,y,z]
  end

  EXAMPLE = <<~EOE
    --- scanner 0 ---
    404,-588,-901
    528,-643,409
    -838,591,734
    390,-675,-793
    -537,-823,-458
    -485,-357,347
    -345,-311,381
    -661,-816,-575
    -876,649,763
    -618,-824,-621
    553,345,-567
    474,580,667
    -447,-329,318
    -584,868,-557
    544,-627,-890
    564,392,-477
    455,729,728
    -892,524,684
    -689,845,-530
    423,-701,434
    7,-33,-71
    630,319,-379
    443,580,662
    -789,900,-551
    459,-707,401

    --- scanner 1 ---
    686,422,578
    605,423,415
    515,917,-361
    -336,658,858
    95,138,22
    -476,619,847
    -340,-569,-846
    567,-361,727
    -460,603,-452
    669,-402,600
    729,430,532
    -500,-761,534
    -322,571,750
    -466,-666,-811
    -429,-592,574
    -355,545,-477
    703,-491,-529
    -328,-685,520
    413,935,-424
    -391,539,-444
    586,-435,557
    -364,-763,-893
    807,-499,-711
    755,-354,-619
    553,889,-390

    --- scanner 2 ---
    649,640,665
    682,-795,504
    -784,533,-524
    -644,584,-595
    -588,-843,648
    -30,6,44
    -674,560,763
    500,723,-460
    609,671,-379
    -555,-800,653
    -675,-892,-343
    697,-426,-610
    578,704,681
    493,664,-388
    -671,-858,530
    -667,343,800
    571,-461,-707
    -138,-166,112
    -889,563,-600
    646,-828,498
    640,759,510
    -630,509,768
    -681,-892,-333
    673,-379,-804
    -742,-814,-386
    577,-820,562

    --- scanner 3 ---
    -589,542,597
    605,-692,669
    -500,565,-823
    -660,373,557
    -458,-679,-417
    -488,449,543
    -626,468,-788
    338,-750,-386
    528,-832,-391
    562,-778,733
    -938,-730,414
    543,643,-506
    -524,371,-870
    407,773,750
    -104,29,83
    378,-903,-323
    -778,-728,485
    426,699,580
    -438,-605,-362
    -469,-447,-387
    509,732,623
    647,635,-688
    -868,-804,481
    614,-800,639
    595,780,-596

    --- scanner 4 ---
    727,592,562
    -293,-554,779
    441,611,-461
    -714,465,-776
    -743,427,-804
    -660,-479,-426
    832,-632,460
    927,-485,-438
    408,393,-506
    466,436,-512
    110,16,151
    -258,-428,682
    -393,719,612
    -211,-452,876
    808,-476,-593
    -575,615,604
    -485,667,467
    -680,325,-822
    -627,-443,-432
    872,-547,-609
    833,512,582
    807,604,487
    839,-516,451
    891,-625,532
    -652,-548,-490
    30,-46,-14
  EOE

  SIMPLE = <<~EOS
    --- scanner 0 ---
    1,0,0
    0,2,0
    0,0,3

    --- scanner 1 ---
    1,0,0
    0,0,2
    0,-3,0
  EOS
end
