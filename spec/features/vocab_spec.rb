require 'rails_helper'

describe Vocab do
  let(:data)   { build(:vocab) }
  let!(:vocab) { create(:vocab) }

  before { skip "scheduled for deprecation" }

  before(:each) do
    login
    click_link t(:vocab_vocabs)
  end

  context "create" do
    it "success" do
      click_link t(:vocab_new)
      fill_in t(:vocab_audio), with: data.audio
      check t(:vocab_burned) if data.burned
      fill_in t(:vocab_category), with: data.category
      fill_in t(:vocab_reading), with: data.reading
      fill_in t(:vocab_kanji), with: data.kanji
      fill_in t(:vocab_level), with: data.level
      fill_in t(:vocab_meaning), with: data.meaning
      click_button t(:save)

      expect(page).to have_title data.kanji

      expect(Vocab.count).to eq 2
      v = Vocab.last

      expect(v.audio).to eq data.audio
      expect(v.burned).to eq data.burned
      expect(v.category).to eq data.category
      expect(v.reading).to eq data.reading
      expect(v.kanji).to eq data.kanji
      expect(v.level).to eq data.level
      expect(v.meaning).to eq data.meaning
      expect(v.morae).to eq Vocab.count_morae(data.reading)
    end

    it "failure" do
      click_link t(:vocab_new)
      check t(:vocab_burned) if data.burned
      fill_in t(:vocab_category), with: data.category
      fill_in t(:vocab_reading), with: data.reading
      fill_in t(:vocab_kanji), with: data.kanji
      fill_in t(:vocab_level), with: data.level
      fill_in t(:vocab_meaning), with: data.meaning
      click_button t(:save)

      expect(page).to have_title t(:vocab_new)
      expect(Vocab.count).to eq 1
      expect(page).to have_css(error, text: "invalid")
    end
  end

  it "delete" do
    click_link vocab.kanji
    click_link t(:edit)
    click_link t(:delete)

    expect(Vocab.count).to eq 0
  end

  it "edit" do
    click_link vocab.kanji
    click_link t(:edit)

    fill_in t(:vocab_kanji), with: data.kanji
    fill_in t(:vocab_reading), with: data.reading
    click_button t(:save)

    expect(Vocab.count).to eq 1
    v = Vocab.last

    expect(v.kanji).to eq data.kanji
    expect(v.reading).to eq data.reading
    expect(v.morae).to eq Vocab.count_morae(data.reading)
  end
end
