# Tasks.
namespace :obs do
  desc "create or update kanji notes for obsidian"
  task :kanji, [:chrs, :nuke] => :environment do |task, args|
    check!
    args.with_defaults(:chrs => "", :nuke => "false")
    nuke = args[:nuke].match?(/\At(rue)?|y(es)?\z/i)
    chrs = args[:chrs].scan(/[\p{Han}]/)
    report("please supply some kanji, e.g. bin/rails obs:kanji\\[新鋭,T\\]", true) unless chrs.size > 0
    chrs.each do |chr|
      if kanji = Wk::Kanji.find_by(character: chr)
        snds = kanji.reading.split(',').map(&:squish).select{ |s| s.match?(/\A[\p{Katakana}\p{Hiragana}]+\z/) }
        rads = kanji.radicals.to_a
        kmake(kanji, snds, rads, nuke)
        snds.each{ |snd| smake(snd, nuke) }
        rads.each{ |rad| rmake(rad, nuke) }
      else
        report "can't find kanji #{chr}"
      end
    end
  end

  # Shared.
  VERSION = 0.1
  MIO = "https://mio.sanichi.me/wk"
  BASE = "/Users/mjo/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/Japanese"
  DIR = %i/kanji radicals sounds/.each_with_object({}) { |d, h| h[d] = "#{BASE}/#{d.to_s.capitalize}"}

  # Create or update a kanji note.
  def kmake(k, sounds, radicals, nuke)
    path = "#{DIR[:kanji]}/#{k.obs_name}.md"
    data = <<~DATA
      ---
      version: #{VERSION}
      level: #{k.level}
      ---

      radicals: #{radicals.map{ |r| "[[#{r.obs_name}]]" }.join(", ")}

      sounds: #{sounds.map{ |s| "[[#{s}]]" }.join(", ")}

      [mio](#{MIO}/kanjis/#{k.id})
    DATA
    gmake("kanji #{k.character}", path, data, nuke)
  end

  # Create or update a radical note.
  def rmake(r, nuke)
    path = "#{DIR[:radicals]}/#{r.obs_name}.md"
    data = <<~DATA
      ---
      version: #{VERSION}
      level: #{r.level}
      ---

      [mio](#{MIO}/radicals/#{r.id})
    DATA
    gmake("radical #{r.name}", path, data, nuke)
  end

  # Create or update a sound note.
  def smake(s, nuke)
    path = "#{DIR[:sounds]}/#{s}.md"
    data = <<~DATA
      ---
      version: #{VERSION}
      ---
    DATA
    gmake("sound #{s}", path, data, nuke)
  end

  # General note creating/updating utility.
  def gmake(mono, path, data, nuke)
    if File.exist?(path)
      if data == File.read(path)
        report "nochnge #{mono}"
      else
        if nuke
          File.open(path, "w"){ |f| f.write(data) }
          report "updated #{mono}"
        else
          report "leaving sound #{mono}"
        end
      end
    else
      File.open(path, "w"){ |f| f.write(data) }
      report "created #{mono}"
    end
  end

  def check!
    report("this task is not for the #{Rails.env} environment", true) unless Rails.env.development?
    report("base directory does not exist", true) unless File.directory?(BASE)
    DIR.each { |dir, path| report("#{dir} directory does not exist", true) unless File.directory?(path) }
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
