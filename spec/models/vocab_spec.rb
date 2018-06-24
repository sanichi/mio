require 'rails_helper'

describe Vocab do
  context "mora" do
    [
      [0, nil, "nil"],
      [0, "", "empty string"],
      [0, "aA最後123", "no hiragana or katakana"],
      [1, "き"],
      [3, "だった"],
      [3, "さいご"],
      [4, "コーヒー"],
      [4, "おととい, いっさくじつ, おとつい"],
      [5, "きょえいしん"],
      [6, "あめりかじん, アメリカじん"],
      [10, "はっぴゃくきゅうじゅうはち"],
    ].each do |data|
      count, string, comment = data
      comment = string if comment.blank?
      it comment do
        vocab = build(:vocab, reading: string)
        expect(vocab.mora).to eq count
      end
    end
  end

  context "self.mora" do
    it "コーヒー" do
      expect(Vocab.mora("コーヒー")).to eq 4
    end
  end
end
