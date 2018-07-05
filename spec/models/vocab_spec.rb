require 'rails_helper'

describe Vocab do
  context "mora" do
    [
      [0, nil, "nil"],
      [0, "", "empty string"],
      [0, "aA最後123", "no hiragana or katakana"],
      [0, "ゅゅ", "only tiny"],
      [1, "き"],
      [3, "だった"],
      [3, "さいご"],
      [4, "コーヒー"],
      [4, "おととい, いっさくじつ, おとつい"],
      [5, "きょえいしん"],
      [6, "あめりかじん, アメリカじん"],
      [10, "はっぴゃくきゅうじゅうはち"],
    ].each do |data|
      count, reading, comment = data
      comment = reading if comment.blank?
      it comment do
        expect(Vocab.count_morae(reading)).to eq count
      end
    end
  end
end
