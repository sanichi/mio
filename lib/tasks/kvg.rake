class KvgZu
  WIDTH = 109
  HEIGHT = 109
  SVG_HEAD = "<svg width=\"_WIDTH_px\" height=\"#{HEIGHT}px\" viewBox=\"0 0 _WIDTH_px #{HEIGHT}px\" xmlns=\"http://www.w3.org/2000/svg\" version\"1.1\">"
  PATH_STYLE = 'fill:none;stroke:black;stroke-width:3'
  GRAY_STYLE = 'fill:none;stroke:#999;stroke-width:3'
  LINE_STYLE = 'stroke:#ddd;stroke-width:2'
  DASH_STYLE = 'stroke:#ddd;stroke-width:2;stroke-dasharray:3 3'
  SPOT_STYLE = 'stroke-width:0;fill:#FF2A00;opacity:0.7;r:5'
  COORD_RE = %r{(?ix:\d+ (?:\.\d+)?)}

  def initialize(xml, id, type = :numbers)
    @id = id
    @type = type
    begin
      @doc = Nokogiri::XML(xml) { |config| config.strict.norecover }
    rescue
      raise "can't parse XML for #{@id}"
    end
  end

  def character
    g = @doc.xpath('//g[@id="kvg:%s"]' % @id)
    raise "can't find element with kvg:id for #{@id}" unless g.length == 1
    @entry = g[0]
    @entry['kvg:element']
  end

  def frames
    paths = @entry.xpath('.//path[@d]')
    strokes = paths.length
    strokes = 1 if strokes == 0
    width = WIDTH * strokes
    svg = []
    svg << SVG_HEAD.gsub('_WIDTH_', width.to_s)

    # outer boundary
    top = 1
    left = 1
    bottom = HEIGHT - 1
    right = width - 1
    svg << line(left, top, right, top, LINE_STYLE)
    svg << line(left, top, left, bottom, LINE_STYLE)
    svg << line(left, bottom, right, bottom, LINE_STYLE)
    svg << line(right, top, right, bottom, LINE_STYLE)

    # vertical divisions
    (1 .. strokes - 1).each do |i|
      svg << line(WIDTH * i, top, WIDTH * i, bottom, LINE_STYLE)
    end

    # inner guides
    h_width = WIDTH/2
    h_height = HEIGHT/2
    svg << line(left, h_height, right, h_height, DASH_STYLE)
    (1 .. strokes).each do |i|
      x = h_width + WIDTH * (i-1) + 1
      svg << line(x, top, x, bottom, DASH_STYLE)
    end

    # strokes
    current = []
    paths.each do |stroke|
      current << stroke.xpath('@d').to_s
      delta = WIDTH * (current.length - 1)
      md = %r{^[LMTm] \s* (#{COORD_RE}) [,\s] (#{COORD_RE})}ix.match(current.last)

      svg << '<g transform="translate(%d 0)">' % delta
      current.each_with_index do |path, i|
        svg << "<path d=\"#{path}\" style=\"#{current.length == i + 1 ? PATH_STYLE : GRAY_STYLE}\" />"
      end
      svg << '<circle cx="%s" cy="%s" style="%s"/>' % [md[1], md[2], SPOT_STYLE] if md
      svg << "</g>"
    end

    # complete and return
    svg.join("\n") + "\n</svg>\n"
  end

  private

  def line(x1, y1, x2, y2, style)
    '<line x1="%d" y1="%d" x2="%d" y2="%d" style="%s"/>' % [x1, y1, x2, y2, style]
  end
end

namespace :kvg do
  desc "update KanjiVG data"
  task :update, [:overwrite, :id] => :environment do |task, args|
    begin
      files = 0
      characters = 0
      kanjis = 0
      duplicates = Hash.new { |h, k| h[k] = [] }
      xml_updates = 0
      frames_updates = 0

      path = Pathname.new("/tmp/kanji")
      raise "#{path} does not exist" unless path.directory?
      paths = path.glob("?????.svg")
      raise "no KanjiVG files found" unless paths.size > 0

      paths.each do |path|
        files += 1
        id = path.to_s[-9..-5]

        next if args[:id] && id != args[:id]

        xml = path.read
        xml.sub!(/<\?xml version="1.0" encoding="UTF-8"\?>/, "")
        xml.sub!(/<!--.*-->/m, "")
        xml.sub!(/\s*<!DOCTYPE.*\]>/m, "")
        xml.sub!(/xmlns="http:\/\/www\.w3\.org\/2000\/svg"/, 'version="1.1"')
        xml.sub!(/<svg/, '<svg xmlns:kvg="https://kanjivg.tagaini.net/"')
        xml.gsub!(/\t/, "  ")

        zu = KvgZu.new(xml, id)

        character = zu.character
        next unless character && character.length == 1
        characters += 1
        duplicates[character].push id
        next if duplicates[character].size > 1

        kanji = Wk::Kanji.find_by(character: character) || next
        kanjis += 1

        if kanji.kvg_xml.blank? || args[:overwrite] == "y"
          kanji.update_columns(kvg_id: id, kvg_xml: xml)
          xml_updates += 1
        end

        if kanji.kvg_frames.blank? || args[:overwrite] == "y"
          kanji.update_columns(kvg_frames: zu.frames)
          frames_updates += 1
        end
      end

      duplicates = duplicates.map do |k,v|
        v.length > 1 ? "#{k}=#{v.join(',')}" : nil
      end.compact

      puts "files........... #{files}"
      puts "duplicates...... #{duplicates.length} (#{duplicates.join(' ')})"
      puts "characters...... #{characters}"
      puts "kanjis.......... #{kanjis}"
      puts "xml updates..... #{xml_updates}"
      puts "frames updates.. #{frames_updates}"
    rescue StandardError => e
      puts e.message
    end
  end
end
