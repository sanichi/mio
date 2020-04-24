namespace :kvg do
  desc "update KanjiVG data"
  task :update, [:overwrite, :skipped] => :environment do |task, args|
    begin
      files = 0
      skipped = []
      characters = 0
      kanjis = 0
      duplicates = Hash.new { |h, k| h[k] = [] }
      updates = 0

      path = Pathname.new("/tmp/kanji")
      raise "#{path} does not exist" unless path.directory?
      paths = path.glob("?????.svg")
      raise "no KanjiVG files found" unless paths.size > 0

      paths.each do |path|
        files += 1
        id = path.to_s[-9..-5]
        xml = path.read
        xml.sub!(/<\?xml version="1.0" encoding="UTF-8"\?>/, "")
        xml.sub!(/<!--.*-->/m, "")
        xml.sub!(/\s*<!DOCTYPE.*\]>/m, "")
        xml.sub!(/xmlns="http:\/\/www\.w3\.org\/2000\/svg"/, 'version="1.1"')
        xml.gsub!(/\t/, "  ")
        unless xml.match(/<g id="kvg:#{id}" kvg:element="(.)"/)
          skipped.push id
          next
        end
        character = $1
        characters += 1
        duplicates[character].push id
        next if duplicates[character].size > 1
        kanji = Wk::Kanji.find_by(character: character) || next
        kanjis += 1
        if kanji.kvg_xml.blank? || args[:overwrite] == "y"
          kanji.update_columns(kvg_id: id, kvg_xml: xml)
          updates += 1
        end
      end

      duplicates = duplicates.map do |k,v|
        v.length > 1 ? "#{k}=#{v.join(',')}" : nil
      end.compact

      puts "files......... #{files}"
      puts "skipped....... #{skipped.length} #{args[:skipped] == "y" ? skipped.sort.join(',') : ''}"
      puts "duplicates.... #{duplicates.length} (#{duplicates.join(' ')})"
      puts "characters.... #{characters}"
      puts "kanjis........ #{kanjis}"
      puts "updates....... #{updates}"
    rescue StandardError => e
      puts e.message
    end
  end
end
