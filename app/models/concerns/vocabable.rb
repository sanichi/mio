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

  included do
    def link_vocabs(text)
      text&.gsub(PATTERN) do |match|
        display = $1
        characters = $2 || display
        vocab = Wk::Vocab.find_by(characters: characters)
        if vocab
          vocab.to_markdown(display: display)
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
