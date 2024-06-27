# Tasks.
namespace :obs do
  desc "create or update obsidian notes given a vocabulary word"
  task :vocab, [:chrs, :nuke] => :environment do |task, args|
    check!
    args.with_defaults(:chrs => "", :nuke => "false")
    nuke = get_nuke(args)
    chrs = args[:chrs]
    report("please supply a word, e.g. bin/rails obs:vobab\\[言葉,T\\]", true) if chrs.blank?
    if vocab = Wk::Vocab.find_by(characters: chrs)
      vmake(vocab, nuke)
    else
      report "can't find vocab #{chrs}", true
    end
    summarize
  end

  desc "create or update obsidian notes given one or more kanji characters"
  task :kanji, [:chrs, :nuke] => :environment do |task, args|
    check!
    args.with_defaults(:chrs => "", :nuke => "false")
    nuke = get_nuke(args)
    chrs = args[:chrs].scan(/[\p{Han}]/)
    report("please supply some kanji, e.g. bin/rails obs:kanji\\[新鋭,T\\]", true) unless chrs.size > 0
    chrs.each do |chr|
      if kanji = Wk::Kanji.find_by(character: chr)
        kmake(kanji, nuke)
      else
        report "can't find kanji #{chr}"
      end
    end
    summarize
  end

  desc "create or update obsidian notes given a vocab level number"
  task :vlevel, [:level, :nuke] => :environment do |task, args|
    check!
    args.with_defaults(:level => "", :nuke => "false")
    nuke = get_nuke(args)
    level = get_level!(args, "bin/rails obs:vlevel\\[9\\]")
    Wk::Vocab.where(level: level).each { |vocab| vmake(vocab, nuke) }
    summarize
  end

  desc "create or update obsidian notes given a kanji level number"
  task :klevel, [:level, :nuke] => :environment do |task, args|
    check!
    args.with_defaults(:level => "", :nuke => "false")
    nuke = get_nuke(args)
    level = get_level!(args, "bin/rails obs:klevel\\[8,y\\]")
    Wk::Kanji.where(level: level).each { |kanji| kmake(kanji, nuke) }
    summarize
  end

  # Shared.
  VERSION = 0.1
  MIO = "https://mio.sanichi.me/wk"
  BASE = "/Users/mjo/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/Japanese"
  DIRS = { v: "Vocabulary", k: "Kanji", r: "Radicals", s: "Sounds" }.transform_values{ |d| "#{BASE}/#{d}" }
  SING = { v: "vocab",      k: "kanji", r: "radical" , s: "sound"  }
  PLRL = { v: "vocabs",     k: "kanji", r: "radicals", s: "sounds" }
  CREATED, UPDATED, NO_CHANGE, LEAVING = %w/created updated nochnge leaving/
  ACTIONS = [CREATED, UPDATED, NO_CHANGE, LEAVING]
  STATS = Hash.new{ |h1, k1| h1[k1] = Hash.new{ |h2, k2| h2[k2] = 0 } }
  
  # Create or update a vocab note.
  def vmake(v, nuke)
    reds = v.readings
    kjis = v.characters.split('').map{ |c| Wk::Kanji.find_by(character: c) }.compact
    path = "#{DIRS[:v]}/#{v.obs_name}.md"
    data = <<~DATA
      ---
      version: #{VERSION}
      level: #{v.level}
      ---

      readings: #{reds.map(&:characters).join(", ")}

      kanji: #{kjis.map{ |k| "[[#{k.obs_name}]]" }.join(", ")}

      [mio](#{MIO}/vocabs/#{v.id})
    DATA
    gmake(v.characters, :v, path, data, nuke)
    kjis.each{ |kji| kmake(kji, nuke) }
  end

  # Create or update a kanji note.
  def kmake(k, nuke)
    rads = k.radicals.to_a
    snds = k.reading.split(',').map(&:squish).select{ |s| s.match?(/\A[\p{Katakana}\p{Hiragana}]+\z/) }
    path = "#{DIRS[:k]}/#{k.obs_name}.md"
    data = <<~DATA
      ---
      version: #{VERSION}
      level: #{k.level}
      ---

      radicals: #{rads.map{ |r| "[[#{r.obs_name}]]" }.join(", ")}

      sounds: #{snds.map{ |s| "[[#{s}]]" }.join(", ")}

      [mio](#{MIO}/kanjis/#{k.id})
    DATA
    gmake(k.character, :k, path, data, nuke)
    rads.each{ |rad| rmake(rad, nuke) }
    snds.each{ |snd| smake(snd, nuke) }
  end

  # Create or update a radical note.
  def rmake(r, nuke)
    path = "#{DIRS[:r]}/#{r.obs_name}.md"
    data = <<~DATA
      ---
      version: #{VERSION}
      level: #{r.level}
      ---

      [mio](#{MIO}/radicals/#{r.id})
    DATA
    gmake(r.name, :r, path, data, nuke)
  end

  # Create or update a sound note.
  def smake(s, nuke)
    path = "#{DIRS[:s]}/#{s}.md"
    data = <<~DATA
      ---
      version: #{VERSION}
      ---
    DATA
    gmake(s, :s, path, data, nuke)
  end

  # General note creating/updating utility.
  def gmake(mono, type, path, data, nuke)
    koto = "#{SING[type]} #{mono}"
    if File.exist?(path)
      if data == File.read(path)
        STATS[type][NO_CHANGE] += 1
        report "#{NO_CHANGE} #{koto}"
      else
        if nuke
          File.open(path, "w"){ |f| f.write(data) }
          STATS[type][UPDATED] += 1
          report "#{UPDATED} #{koto}"
        else
          STATS[type][LEAVING] += 1
          report "#{LEAVING} #{koto}"
        end
      end
    else
      File.open(path, "w"){ |f| f.write(data) }
      STATS[type][CREATED] += 1
      report "#{CREATED} #{koto}"
    end
  end

  def summarize
    puts "         %7s %7s %7s %7s" % ACTIONS
    PLRL.each do |t, name|
      printf "%-8s ", name
      ACTIONS.each do |a|
        printf "  %-3d   ", STATS[t][a]
      end
      printf "\n"
    end
  end

  def check!
    report("this task is not for the #{Rails.env} environment", true) unless Rails.env.development?
    report("base directory does not exist", true) unless File.directory?(BASE)
    DIRS.each { |dir, path| report("#{dir} directory does not exist", true) unless File.directory?(path) }
  end

  def get_nuke(args)
    args[:nuke].match?(/\At(rue)?|y(es)?\z/i)
  end

  def get_level!(args, example)
    level = args[:level].to_i
    report("please supply a level between 1 and 60, e.g. #{example}", true) unless level > 0 && level <= 60
    level
  end

  def report(msg, error=false)
    if error
      puts "ERROR: #{msg}"
      exit 1
    else
      puts msg
    end
  end
end
