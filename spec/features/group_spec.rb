require 'rails_helper'

describe Wk::Group do
  let!(:family)      { create(:wk_vocab, characters: "家庭") }
  let!(:assumption)  { create(:wk_vocab, characters: "仮定") }
  let!(:process)     { create(:wk_vocab, characters: "過程") }
  let!(:supposition) { create(:wk_vocab, characters: "想定") }
  let!(:hypothesis)  { create(:wk_vocab, characters: "仮説") }
  let!(:group)       { create(:wk_group, category: "synonyms", vocab_list: "仮定 想定 仮説") }
  let(:data)         { build(:wk_group, category: "sounds_like", vocab_list: "家庭 仮定 過程") }

  before(:each) do
    login
    click_link t(:wk_group_groups)
  end

  context "create" do
    it "success" do
      click_link t(:wk_group_new)
      select t("wk.group.categories.#{data.category}"), from: t("wk.group.category")
      fill_in t(:wk_group_vocab__list), with: data.vocab_list
      click_button t(:save)

      expect(page).to have_title t(:wk_group_group)

      expect(Wk::Group.count).to eq 2
      g = Wk::Group.last

      expect(g.category).to eq data.category
      expect(g.vocab_list).to eq data.vocab_list

      expect(g.vocabs.count).to eq 3
      expect(g.vocabs).to include(family)
      expect(g.vocabs).to include(assumption)
      expect(g.vocabs).to include(process)
      expect(family.groups.count).to eq 1
      expect(family.groups).to include(g)
      expect(assumption.groups.count).to eq 2
      expect(assumption.groups).to include(g)
      expect(process.groups.count).to eq 1
      expect(process.groups).to include(g)
    end

    it "failure" do
      click_link t(:wk_group_new)
      fill_in t(:wk_group_vocab__list), with: data.vocab_list
      click_button t(:save)

      expect(page).to have_title t(:wk_group_new)
      expect(Wk::Group.count).to eq 1
      expect(page).to have_css(error, text: "not included")
    end
  end

  context "edit" do
    it "success" do
      visit edit_wk_group_path(group)
      expect(page).to have_title t(:wk_group_edit)

      fill_in t(:wk_group_vocab__list), with: "仮定 想定"
      click_button t(:save)

      expect(page).to have_title t(:wk_group_group)

      expect(Wk::Group.count).to eq 1
      g = Wk::Group.last

      expect(g.vocab_list).to eq "仮定 想定"
      expect(g.vocabs.count).to eq 2
      expect(g.vocabs).to include(assumption)
      expect(g.vocabs).to include(supposition)
      expect(assumption.groups.count).to eq 1
      expect(assumption.groups).to include(g)
      expect(supposition.groups.count).to eq 1
      expect(supposition.groups).to include(g)
      expect(hypothesis.groups.count).to eq 0
    end
  end

  context "delete" do
    it "success" do
      expect(Wk::Group.count).to eq 1

      visit edit_wk_group_path(group)
      click_link t(:delete)

      expect(page).to have_title t(:wk_group_groups)
      expect(Wk::Group.count).to eq 0
      expect(assumption.groups).to be_empty
      expect(supposition.groups).to be_empty
      expect(hypothesis.groups).to be_empty
    end
  end
end
