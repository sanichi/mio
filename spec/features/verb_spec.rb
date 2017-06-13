require 'rails_helper'

describe Verb do
  let(:data)   { build(:verb) }
  let!(:verb)  { create(:verb) }
  let!(:vocab) { create(:vocab, kanji: "預ける") }

  before(:each) do
    login
    click_link t(:verb_verbs)
  end

  context "create" do
    it "success" do
      click_link t(:verb_new)
      select t(:verb_categories)[data.category.to_sym], from: t(:verb_category)
      fill_in t(:vocab_reading), with: data.reading
      fill_in t(:vocab_kanji), with: data.kanji
      fill_in t(:vocab_meaning), with: data.meaning
      data.transitive ? check(t(:verb_transitivity)) : uncheck(t(:verb_transitivity))
      click_button t(:save)

      expect(page).to have_title data.kanji

      expect(Verb.count).to eq 2
      v = Verb.last

      expect(v.category).to eq data.category
      expect(v.reading).to eq data.reading
      expect(v.kanji).to eq data.kanji
      expect(v.meaning).to eq data.meaning
      expect(v.transitive).to eq data.transitive
      expect(v.vocab).to be_nil
    end

    it "linked vocab" do
      click_link t(:verb_new)
      select t(:verb_categories)[data.category.to_sym], from: t(:verb_category)
      fill_in t(:vocab_reading), with: data.reading
      fill_in t(:vocab_kanji), with: vocab.kanji
      fill_in t(:vocab_meaning), with: data.meaning
      data.transitive ? check(t(:verb_transitivity)) : uncheck(t(:verb_transitivity))
      click_button t(:save)

      expect(page).to have_title vocab.kanji

      expect(Verb.count).to eq 2
      v = Verb.last

      expect(v.category).to eq data.category
      expect(v.reading).to eq data.reading
      expect(v.kanji).to eq vocab.kanji
      expect(v.meaning).to eq data.meaning
      expect(v.transitive).to eq data.transitive
      expect(v.vocab).to eq vocab
    end

    it "failure" do
      click_link t(:verb_new)
      select t(:verb_categories)[data.category.to_sym], from: t(:verb_category)
      fill_in t(:vocab_reading), with: data.reading
      fill_in t(:vocab_kanji), with: data.kanji
      data.transitive ? check(t(:verb_transitivity)) : uncheck(t(:verb_transitivity))
      click_button t(:save)

      expect(page).to have_title t(:verb_new)
      expect(Verb.count).to eq 1
      expect(page).to have_css(error, text: "blank")
    end
  end

  it "delete" do
    click_link verb.kanji
    click_link t(:edit)
    click_link t(:delete)

    expect(Verb.count).to eq 0
  end

  it "edit" do
    click_link verb.kanji
    click_link t(:edit)

    fill_in t(:vocab_kanji), with: data.kanji
    click_button t(:save)

    expect(Verb.count).to eq 1
    v = Verb.last

    expect(v.kanji).to eq data.kanji
  end
end
