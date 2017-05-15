require 'rails_helper'

describe Vocab do
  # something's not right with the factory
  data = {
    audio:   "b80ece728d726fdc1faac8e3e663201252bb5a8f.mp3",
    kana:    "いっぽんぎ",
    kanji:   "一本気",
    meaning: "one track mind",
    level:   1,
  }

  before(:each) do
    login
    click_link t(:vocab_vocabs)
  end

  context "create" do
    it "success" do
      click_link t(:vocab_new)
      fill_in t(:vocab_audio), with: data[:audio]
      fill_in t(:vocab_kana), with: data[:kana]
      fill_in t(:vocab_kanji), with: data[:kanji]
      fill_in t(:vocab_level), with: data[:level]
      fill_in t(:vocab_meaning), with: data[:meaning]
      click_button t(:save)

      expect(page).to have_title data[:kanji]

      expect(Vocab.count).to eq 1
      v = Vocab.last

      expect(v.audio).to eq data[:audio]
      expect(v.kana).to eq data[:kana]
      expect(v.kanji).to eq data[:kanji]
      expect(v.level).to eq data[:level]
      expect(v.meaning).to eq data[:meaning]
      expect(v.kanji_correct).to eq 0
      expect(v.kanji_incorrect).to eq 0
      expect(v.meaning_correct).to eq 0
      expect(v.meaning_incorrect).to eq 0
    end

    it "failure" do
      click_link t(:vocab_new)
      fill_in t(:vocab_kana), with: data[:kana]
      fill_in t(:vocab_kanji), with: data[:kanji]
      fill_in t(:vocab_level), with: data[:level]
      fill_in t(:vocab_meaning), with: data[:meaning]
      click_button t(:save)

      expect(page).to have_title t(:vocab_new)
      expect(Vocab.count).to eq 0
      expect(page).to have_css(error, text: "invalid")
    end
  end
end
