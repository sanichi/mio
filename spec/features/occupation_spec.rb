require 'rails_helper'

describe Occupation do
  let(:data)        { build(:occupation) }
  let!(:occupation) { create(:occupation) }
  let!(:vocab)      { create(:vocab) }

  before(:each) do
    login
    click_link t(:vocab_occupation_occupations)
  end

  context "create" do
    it "success with no matched kanji" do
      click_link t(:vocab_occupation_new)
      fill_in t(:vocab_kanji), with: data.kanji
      fill_in t(:vocab_reading), with: data.reading
      fill_in t(:vocab_meaning), with: data.meaning
      click_button t(:save)

      expect(page).to have_title data.kanji

      expect(Occupation.count).to eq 2
      o = Occupation.last

      expect(o.kanji).to eq data.kanji
      expect(o.meaning).to eq data.meaning
      expect(o.reading).to eq data.reading
      expect(o.vocab).to be_nil
    end

    it "success with matched kanji" do
      click_link t(:vocab_occupation_new)
      fill_in t(:vocab_kanji), with: vocab.kanji
      click_button t(:save)

      expect(page).to have_title vocab.kanji

      expect(Occupation.count).to eq 2
      o = Occupation.last

      expect(o.kanji).to eq vocab.kanji
      expect(o.meaning).to eq vocab.meaning
      expect(o.reading).to eq vocab.reading
      expect(o.vocab).to eq vocab
    end

    it "failure" do
      click_link t(:vocab_occupation_new)
      fill_in t(:vocab_kanji), with: data.kanji
      fill_in t(:vocab_meaning), with: data.meaning
      click_button t(:save)

      expect(page).to have_title t(:vocab_occupation_new)
      expect(Occupation.count).to eq 1
      expect(page).to have_css(error, text: "blank")
    end
  end

  it "delete" do
    click_link occupation.kanji
    click_link t(:edit)
    click_link t(:delete)

    expect(Occupation.count).to eq 0
  end
  #
  # it "edit" do
  #   click_link vocab.kanji
  #   click_link t(:edit)
  #
  #   fill_in t(:vocab_kanji), with: data.kanji
  #   click_button t(:save)
  #
  #   expect(Vocab.count).to eq 1
  #   v = Vocab.last
  #
  #   expect(v.kanji).to eq data.kanji
  # end
end
