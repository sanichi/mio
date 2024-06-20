# Tasks.
namespace :obs do
  desc "create or update kanji notes for obsidian"
  task :kanji, [:chrs, :nuke] => :environment do |task, args|
    check!
    args.with_defaults(:chrs => "", :nuke => "false")
    nuke = args[:nuke].match?(/\At(rue)?|y(es)?\z/i)
    chrs = args[:chrs].scan(/[\p{Han}]/)
    report("please supply some kanji, e.g. bin/rails obs:kanji\\[新鋭,T\\]", true) unless chrs.size > 0
    chrs.each do |c|
      if kanji = Wk::Kanji.find_by(character: c)
        sounds = kanji.reading.split(',').map(&:squish).select{ |s| s.match?(/\A[\p{Katakana}\p{Hiragana}]+\z/) }
        kmake(kanji, sounds, nuke)
        sounds.each{ |sound| smake(sound, nuke) }
      else
        report "can't find kanji #{c}"
      end
    end
  end

  # Shared.
  VERSION = 0.1
  MIO = "https://mio.sanichi.me/wk"
  BASE = "/Users/mjo/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/Japanese"
  KDIR = "#{BASE}/Kanji"
  RDIR = "#{BASE}/Radicals"
  SDIR = "#{BASE}/Sounds"

  # Kanji utilities.
  def kfile(k) = "#{k.character} #{k.meaning}.md"
  def kdata(k, sounds)
    <<~DATA
      ---
      version: #{VERSION}
      ---

      #{sounds.map{ |s| "[[#{s}]]" }.join(", ") }

      [mio](#{MIO}/kanjis/#{k.id})
    DATA
  end
  def kmake(k, sounds, nuke)
    data = kdata(k, sounds)
    path = "#{KDIR}/#{kfile(k)}"
    gmake("kanji #{k.character}", path, data, nuke)
  end

  # Sounds (readings) utilities.
  def sfile(s) = "#{s}.md"
  def sdata(s)
    <<~DATA
      ---
      version: #{VERSION}
      ---
    DATA
  end
  def smake(s, nuke)
    data = sdata(s)
    path = "#{SDIR}/#{sfile(s)}"
    gmake("sound #{s}", path, data, nuke)
  end

  # General file making utility.
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
    report("kanji directory does not exist", true) unless File.directory?(KDIR)
    report("radicals directory does not exist", true) unless File.directory?(RDIR)
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
