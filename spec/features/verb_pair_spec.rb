require 'rails_helper'

describe Vocab do
  let!(:vt1)       { create(:vocab, kanji: "上げる", category: "transitive verb, ichidan verb") }
  let!(:vi1)       { create(:vocab, kanji: "上がる", category: "intransitive verb, godan verb") }
  let!(:vt2)       { create(:vocab, kanji: "切る", category: "transitive verb, godan verb") }
  let!(:vi2)       { create(:vocab, kanji: "切れる", category: "intransitive verb, ichidan verb") }
  let!(:verb_pair) { create(:verb_pair, transitive: vt1, intransitive: vi1, category: "eru_aru") }
  let(:data)       { build(:verb_pair, transitive: vt2, intransitive: vi2, category: "u_eru") }

  before(:each) do
    login
    click_link t(:verb__pair_verb__pairs)
  end

  context "create" do
    it "success" do
      click_link t(:verb__pair_new)
      select data.transitive.kanji_reading, from: t(:verb__pair_transitive)
      select data.intransitive.kanji_reading, from: t(:verb__pair_intransitive)
      select I18n.t("verb_pair.categories.#{data.category}"), from: t(:verb__pair_category)
      click_button t(:save)

      expect(page).to have_title data.title

      expect(VerbPair.count).to eq 2
      p = VerbPair.last

      expect(p.transitive_id).to eq data.transitive.id
      expect(p.intransitive_id).to eq data.intransitive.id
      expect(p.category).to eq data.category
    end

    it "failure" do
      click_link t(:verb__pair_new)
      select data.transitive.kanji_reading, from: t(:verb__pair_transitive)
      select data.intransitive.kanji_reading, from: t(:verb__pair_intransitive)
      click_button t(:save)

      expect(page).to have_title t(:verb__pair_new)
      expect(VerbPair.count).to eq 1
      expect(page).to have_css(error, text: "not included")
    end
  end

  it "delete" do
    click_link I18n.t("verb_pair.categories.#{verb_pair.category}")
    click_link t(:edit)
    click_link t(:delete)

    expect(VerbPair.count).to eq 0
  end

  it "edit" do
    click_link I18n.t("verb_pair.categories.#{verb_pair.category}")
    click_link t(:edit)

    select data.transitive.kanji_reading, from: t(:verb__pair_transitive)
    click_button t(:save)

    expect(VerbPair.count).to eq 1
    p = VerbPair.last

    expect(p.transitive_id).to eq data.transitive.id
  end
end
