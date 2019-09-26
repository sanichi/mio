module Wk
  MAX_LEVEL = 60

  def self.table_name_prefix
    "wk_"
  end

  def self.update(days=nil)
    Wk::Radical.update(days)
    Wk::Kanji.update(days)
    Wk::Vocab.update(days)
    Wk::Reading.update(days)
  end
end
