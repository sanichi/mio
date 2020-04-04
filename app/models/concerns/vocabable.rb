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
    <
    ([^><])
    >
  /x

  included do
    def link_vocabs(text)
      return text unless text.present?
      text.gsub(PATTERN) do |match|
        display = $1
        characters = $2 || display
        vocab = Wk::Vocab.find_by(characters: characters)
        if vocab
          vocab.to_markdown(display: display)
        else
          match
        end
      end.gsub(KPATTERN) do |match|
        character = $1
        kanji = Wk::Kanji.find_by(character: character)
        if kanji
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
