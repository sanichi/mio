require 'rails_helper'

describe GrammarGroup do
  let(:data)   { build(:grammar_group) }
  let!(:group) { create(:grammar_group) }

  before(:each) do
    login
    click_link t("grammar.group.groups")
  end

  context "create" do
    it "success" do
      click_link t("grammar.group.new")
      fill_in t("grammar.title"), with: data.title
      click_button t("save")

      expect(page).to have_title data.title

      expect(GrammarGroup.count).to eq 2
      g = GrammarGroup.last

      expect(g.title).to eq data.title
    end

    it "failure" do
      click_link t("grammar.group.new")
      click_button t("save")

      expect(page).to have_title t("grammar.group.new")
      expect(GrammarGroup.count).to eq 1
      expect_error(page, "blank")
    end
  end

  context "edit" do
    it "title" do
      click_link group.title
      click_link t("edit")

      expect(page).to have_title t("grammar.group.edit")

      fill_in t("grammar.title"), with: data.title
      click_button t("save")

      expect(page).to have_title data.title
      expect(GrammarGroup.count).to eq 1
      g = GrammarGroup.last
      expect(g.title).to eq data.title
    end
  end

  context "delete" do
    it "success" do
      expect(GrammarGroup.count).to eq 1

      click_link group.title
      click_link t("edit")
      click_link t("delete")

      expect(page).to have_title t("grammar.group.groups")
      expect(GrammarGroup.count).to eq 0
    end
  end
end
