module Vocabable
  extend ActiveSupport::Concern

  PATTERN = /
    \{
    ([^}|]+)
    (?:\|([^}|]+))?
    \}
  /x
  NRETTAP = /
    \[
    ([^\]\)]+)
    \]
    \(
    \/wk\/vocabs\/
    ([^\]\)]+)
    \)
  /x
  KPATTERN = /
    ([«<])
    ([^«<>»|])
    (?:\|([^«<>»|]+))?
    [»>]
  /x
  PPATTERN = /
    [「]
    ([^「」|]+)
    (?:\|([^「」|]+))?
    [」]
  /x
  HKPATTERN = /
    \≤
    ([^≤≥|]+)
    (?:\|([^≤≥|]+))?
    \≥
  /x

  included do
    def link_vocabs(text)
      return text unless text.present?
      text.gsub(PATTERN) do |match|
        display = $1
        characters = $2 || display
        if vocab = Wk::Vocab.find_by(characters: characters)
          vocab.to_markdown(display: display)
        else
          match
        end
      end.gsub(KPATTERN) do |match|
        bracket = $1
        display = $2
        character = $3 || display
        if bracket == '<' && note = Note.find_by(series: "Daily", title: character)
          note.to_markdown(display: display)
        elsif kanji = Wk::Kanji.find_by(character: character)
          kanji.to_markdown(display: display)
        else
          match
        end
      end.gsub(PPATTERN) do |match|
        display = $1
        jname = $2 || display
        if place = Place.find_by(jname: jname)
          place.to_markdown(display: display)
        else
          match
        end
      end.gsub(HKPATTERN) do |match|
        display = $1
        characters = $2 || display
        if kana = Wk::Kana.find_by(characters: characters)
          kana.to_markdown(display: display)
        else
          match
        end
      end
    end

    def unlink_vocabs(text)
      text&.gsub(NRETTAP) do |match|
        display = $1
        characters = $2
        if characters == display
          "{#{characters}}"
        else
          "{#{display}|#{characters}}"
        end
      end
    end
  end
end
