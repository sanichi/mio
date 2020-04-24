namespace :kvg do
  desc "update KanjiVG data"
  task :update, [:overwrite, :skipped] => :environment do |task, args|
    files = 0
    skipped = []
    characters = 0
    kanjis = {}
    duplicates = Hash.new { |h, k| h[k] = [] }
    updates = 0
    begin
      path = Pathname.new("/tmp/kanjivg")
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
        kanji = Wk::Kanji.find_by(character: character) || next
        duplicates[character].push id
        next if duplicates[character].size > 1
        kanjis[character] = true
        if kanji.kvg_xml&.empty? || args[:overwrite] == "y"
          kanji.update_columns(kvg_id: id, kvg_xml: xml)
          updates += 1
        end
      end
    rescue StandardError => e
      puts e.message
    end
    duplicates.delete_if { |k,v| v.size == 1 }
    dupdetails = duplicates.map { |k,v| "#{k}=#{v.join(',')}" }

    puts "files......... #{files}"
    puts "skipped....... #{skipped.length} #{args[:skipped] == "y" ? skipped.sort.join(',') : ''}"
    puts "duplicates.... #{dupdetails.length} (#{dupdetails.join(' ')})"
    puts "characters.... #{characters}"
    puts "kanjis........ #{kanjis.size}"
    puts "updates....... #{updates}"
  end
end
