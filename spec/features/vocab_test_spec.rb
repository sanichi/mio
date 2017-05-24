require 'rails_helper'

describe VocabTest do
  let(:data) { build(:vocab_test) }
  let!(:vtest) { create(:vocab_test) }

  before(:each) do
    login
    click_link t(:vocab_test_tests)
  end

  context "create" do
    it "success" do
      click_link t(:vocab_test_new)
      select t(:vocab_test)[data.category.to_sym], from: t(:vocab_test_category)
      select data.level, from: t(:vocab_level)
      click_button t(:save)

      expect(page).to have_title t(:vocab_test_test)

      expect(VocabTest.count).to eq 2
      t = VocabTest.last

      expect(t.attempts).to eq 0
      expect(t.category).to eq data.category
      expect(t.correct).to eq 0
      expect(t.hit_rate).to eq 0
      expect(t.level).to eq data.level
      expect(t.progress_rate).to eq 0
      expect(t.total).to eq 0
    end

    it "failure" do
      click_link t(:vocab_test_new)
      select t(:vocab_test)[data.category.to_sym], from: t(:vocab_test_category)
      click_button t(:save)

      expect(page).to have_title t(:vocab_test_new)
      expect(page).to have_css(error, text: "not a number")
      expect(VocabTest.count).to eq 1
    end
  end

  it "destroy" do
    click_link vtest.level_skill
    click_link t(:delete)

    expect(page).to have_title t(:vocab_test_tests)
    expect(VocabTest.count).to eq 0
  end
end
