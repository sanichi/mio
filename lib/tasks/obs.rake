namespace :obs do
  desc "create or update kanji notes for obsidian"
  task :kanji, [:chrs, :nuke] => :environment do |task, args|
    check!
    args.with_defaults(:chrs => "", :nuke => "false")
    nuke = args[:nuke].match?(/\At(rue)?|y(es)?\z/i)
    chrs = args[:chrs].scan(/[\p{Han}]/)
    report("please supply some kanji, e.g. bin/rails obs:kanji\\[新鋭,T\\]", true) unless chrs.size > 0
    chrs.each do |c|
      if k = Wk::Kanji.find_by(character: c)
        data = kdata(k)
        path = "#{KDIR}/#{kfile(k)}"
        if File.exist?(path)
          if data == File.read(path)
            report "unmoved kanji #{c}"
          else
            if nuke
              File.open(path, "w"){ |f| f.write(data) }
              report "updated kanji #{c}"
            else
              report "leaving kanji #{c}"
            end
          end
        else
          File.open(path, "w"){ |f| f.write(data) }
          report "created kanji #{c}"
        end
      else
        report "can't find kanji #{c}"
      end
    end
  end

  VERSION = 0.1
  MIO = "https://mio.sanichi.me/wk"
  BASE = "/Users/mjo/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/Japanese"
  KDIR = "#{BASE}/Kanji"
  RDIR = "#{BASE}/Radicals"

  def kfile(k) = "#{k.character} #{k.meaning}.md"
  def kdata(k)
    <<~DATA
      ---
      version: #{VERSION}
      ---

      [[#{k.character} #{k.meaning}]]

      #{k.reading}

      [mio](#{MIO}/kanjis/#{k.id})
    DATA
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
