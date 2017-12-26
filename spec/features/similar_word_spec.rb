require 'rails_helper'

describe SimilarWord do
  let(:data)          { build(:similar_word) }
  let!(:similar_word) { create(:similar_word) }

  before(:each) do
    login
    click_link t(:vocab_similar_words)
  end

  context "create" do
    it "success" do
      click_link t(:vocab_similar_new)
      fill_in t(:vocab_readings), with: data.readings
      click_button t(:save)

      expect(page).to have_title similar_word.display(data.readings)

      expect(SimilarWord.count).to eq 2
      w = SimilarWord.last

      expect(w.readings).to eq data.readings
    end

    it "failure" do
      click_link t(:vocab_similar_new)
      fill_in t(:vocab_readings), with: similar_word.readings
      click_button t(:save)

      expect(page).to have_title t(:vocab_similar_new)
      expect(SimilarWord.count).to eq 1
      expect(page).to have_css(error, text: "taken")
    end
  end

  context "edit" do
    it "success" do
      click_link similar_word.display
      click_link t(:edit)

      expect(page).to have_title t(:vocab_similar_edit)
      fill_in t(:vocab_readings), with: data.readings.split.reverse.join("\t")
      click_button t(:save)

      expect(page).to have_title similar_word.display(data.readings)

      expect(SimilarWord.count).to eq 1
      w = SimilarWord.last

      expect(w.readings).to eq data.readings
    end

    it "failure" do
      click_link similar_word.display
      click_link t(:edit)

      fill_in t(:vocab_readings), with: ""
      click_button t(:save)

      expect(page).to have_title t(:vocab_similar_edit)
      expect(page).to have_css(error, text: "invalid")
    end
  end

  context "delete" do
    it "success" do
      expect(SimilarWord.count).to eq 1

      click_link similar_word.display
      click_link t(:delete)

      expect(page).to have_title t(:vocab_similar_words)
      expect(SimilarWord.count).to eq 0
    end
  end
end
