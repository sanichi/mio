class Aoc::Y2021d12 < Aoc
  def answer(part)
    Graph.new(input).paths(part == 1 ? false : true)
  end

  class Graph
    attr_reader :successors

    def initialize(string)
      @successors = Hash.new{|h, k| h[k] = []}
      string.each_line(chomp: true) do |line|
        raise "invalid input" unless line.match(/\A([A-Z]+|[a-z]+)-([A-Z]+|[a-z]+)\z/)
        raise "invalid connection" if $1 == $2
        @successors[$1].push($2) unless $2 == "start"
        @successors[$2].push($1) unless $1 == "start"
      end
      raise "no start" unless @successors.include?("start")
      raise "no end" unless @successors.include?("end")
    end

    def paths(allow)
      found = []
      recurse("start", [], found, allow)
      found.size
    end

    private

    def recurse(node, path, found, allow)
      path.push(node)
      if node == "end"
        found.append(path.dup)
      else
        successors[node].each do |s|
          if big?(s) || !path.include?(s) || (allow && uniq?(path))
            recurse(s, path, found, allow)
          end
        end
      end
      path.pop()
    end

    def big?(node)
      node.ord < 97 # "a".ord == 97, "Z".ord == 90
    end

    def uniq?(path)
      smallones = path.select{|n| !big?(n)}
      smallones.uniq.length == smallones.length
    end
  end

  EXAMPLE1 = <<~EOE1
    start-A
    start-b
    A-c
    A-b
    b-d
    A-end
    b-end
  EOE1

  EXAMPLE2 = <<~EOE2
    dc-end
    HN-start
    start-kj
    dc-start
    dc-HN
    LN-dc
    HN-end
    kj-sa
    kj-HN
    kj-dc
  EOE2

  EXAMPLE3 = <<~EOE3
    fs-end
    he-DX
    fs-he
    start-DX
    pj-DX
    end-zg
    zg-sl
    zg-pj
    pj-he
    RW-he
    fs-DX
    pj-RW
    zg-RW
    start-pj
    he-WI
    zg-he
    pj-fs
    start-RW
  EOE3
end
