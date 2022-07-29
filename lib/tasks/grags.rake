namespace :grammar do
  def scrape_grammars
    groups = Hash.new(0)
    Grammar.by_ref.all.each do |g|
      ids = scrape_grammar(g.note, g.id)
      puts "%-7s %2d %s %s" % [g.ref, g.id, g.title, ids.to_s]
      groups[ids.to_s] += 1 unless ids.empty?
    end
    groups.each_pair do |group, count|
      puts "#{group} => #{count}"
    end
  end

  def scrape_grammar(note, id)
    state = 1
    ids = []
    note.each_line do |line|
      case line
      when /\ARelated:\s*\z/
        if state == 1
          state = 2
        else
          raise "found related header in wrong state"
        end
      when /\A\* \[[^\]]*\]\(\/grammars\/(\d+)\)\s*\z/
        ids.push($1.to_i) if state == 2
        raise "found related item in wrong state" if state == 1
      when /\A\* [^\[\(\]\)]+\z/
        ids.push(id) if state == 2
      else
        puts "??? #{line}" unless state == 1 || line.match?(/\A\s*\z/)
      end
    end
    ids
  end

  desc "split grammars into groups"
  task :groups, [:create] => :environment do |task, args|
    create = args[:create] == "c"
    begin
      scrape_grammars
    rescue => e
      puts e.message
    end
  end
end
