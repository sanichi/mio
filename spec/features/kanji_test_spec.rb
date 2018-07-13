require 'rails_helper'

describe KanjiTest do
  let(:data)   { build(:kanji_test) }
  let!(:ktest) { create(:kanji_test) }

  before(:each) do
    login
    click_link t(:vocab_kanji__test_tests)
  end

  context "create" do
    it "success" do
      click_link t(:vocab_kanji__test_new)
      select data.level, from: t(:vocab_level)
      click_button t(:save)

      expect(page).to have_title t(:vocab_kanji__test_test)

      expect(KanjiTest.count).to eq 2
      t = KanjiTest.last

      expect(t.attempts).to eq 0
      expect(t.correct).to eq 0
      expect(t.hit_rate).to eq 0
      expect(t.level).to eq data.level
      expect(t.progress_rate).to eq 0
      expect(t.total).to eq 0
    end

    it "failure" do
      click_link t(:vocab_kanji__test_new)
      click_button t(:save)

      expect(page).to have_title t(:vocab_kanji__test_new)
      expect(page).to have_css(error, text: "not a number")
      expect(KanjiTest.count).to eq 1
    end
  end

  it "destroy" do
    click_link ktest.short_updated_date
    click_link t(:delete)

    expect(page).to have_title t(:vocab_kanji__test_tests)
    expect(KanjiTest.count).to eq 0
  end
end
