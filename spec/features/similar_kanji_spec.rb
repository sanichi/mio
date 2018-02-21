require 'rails_helper'

describe SimilarKanji do
  let(:data)           { build(:similar_kanji) }
  let!(:similar_kanji) { create(:similar_kanji) }

  before(:each) do
    login
    click_link t(:vocab_similar_kanjis)
  end

  context "create" do
    it "success" do
      click_link t(:vocab_similar_kanji_new)
      fill_in t(:vocab_kanjis), with: data.kanjis
      click_button t(:save)

      expect(page).to have_title data.kanjis

      expect(SimilarKanji.count).to eq 2
      k = SimilarKanji.last

      expect(k.kanjis).to eq data.kanjis
    end

    it "failure" do
      click_link t(:vocab_similar_kanji_new)
      fill_in t(:vocab_kanjis), with: similar_kanji.kanjis
      click_button t(:save)

      expect(page).to have_title t(:vocab_similar_kanji_new)
      expect(SimilarKanji.count).to eq 1
      expect(page).to have_css(error, text: "taken")
    end
  end

  context "edit" do
    it "success" do
      click_link similar_kanji.kanjis
      click_link t(:edit)

      expect(page).to have_title t(:vocab_similar_kanji_edit)
      fill_in t(:vocab_kanjis), with: data.kanjis.split.reverse.join("\t")
      click_button t(:save)

      expect(page).to have_title data.kanjis

      expect(SimilarKanji.count).to eq 1
      k = SimilarKanji.last

      expect(k.kanjis).to eq data.kanjis
    end

    it "failure" do
      click_link similar_kanji.kanjis
      click_link t(:edit)

      fill_in t(:vocab_kanjis), with: ""
      click_button t(:save)

      expect(page).to have_title t(:vocab_similar_kanji_edit)
      expect(page).to have_css(error, text: "too short")
    end
  end

  context "delete" do
    it "success" do
      expect(SimilarKanji.count).to eq 1

      click_link similar_kanji.kanjis
      click_link t(:delete)

      expect(page).to have_title t(:vocab_similar_kanjis)
      expect(SimilarKanji.count).to eq 0
    end
  end
end
