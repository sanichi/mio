module Wk
  MAX_LEVEL = 60

  def self.table_name_prefix
    "wk_"
  end

  # in development - check for problems
  #   bin/rails r Wk::Radical.update
  #   bin/rails r Wk::Kanji.update
  #   bin/rails r Wk::Vocab.update
  #   bin/rails r Wk::Kana.update
  #   bin/rails r Wk::Reading.update
  #   bin/rails r Wk::VerbPair.update
  # individual vocabs can be investigated using their WK ID
  #   bin/rails r 'Wk::Vocab.subject(1234)'
  # on production, once problems resolved
  #   RAILS_ENV=production bin/rails r Wk.update
  #   RAILS_ENV=production bin/rails r Wk::VerbPair.update
  def self.update(days=nil)
    Wk::Radical.update(days)
    Wk::Kanji.update(days)
    Wk::Vocab.update(days)
    Wk::Kana.update(days)
    Wk::Reading.update(days)
  end
end
