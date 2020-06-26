module Wk
  MAX_LEVEL = 60

  def self.table_name_prefix
    "wk_"
  end

  # in development - check for problems
  # bin/rails r Wk::Radical.update
  # bin/rails r Wk::Kanji.update
  # bin/rails r Wk::Vocab.update
  # bin/rails r Wk::Reading.update
  # on production, once problems resolved
  # RAILS_ENV=production bin/rails r Wk.update
  def self.update(days=nil)
    Wk::Radical.update(days)
    Wk::Kanji.update(days)
    Wk::Vocab.update(days)
    Wk::Reading.update(days)
  end
end
