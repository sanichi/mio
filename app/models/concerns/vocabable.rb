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
  NPATTERN = /
    <
    ([^><])
    >
  /x
  KPATTERN = /
    «
    ([^«»])
    »
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
        character = $1
        if kanji = Wk::Kanji.find_by(character: character)
          kanji.to_markdown
        else
          match
        end
      end.gsub(NPATTERN) do |match|
        character = $1
        if note = Note.find_by(series: "Daily", title: character)
          note.to_markdown
        elsif kanji = Wk::Kanji.find_by(character: character)
          kanji.to_markdown
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
