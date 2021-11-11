require 'rails_helper'

describe Grammar do
  let(:data)     { build(:grammar) }
  let!(:grammar) { create(:grammar) }

  before(:each) do
    login
    click_link t("grammar.grammar")
  end

  context "create" do
    it "success" do
      click_link t("grammar.new")
      fill_in t("grammar.ref"), with: data.ref
      fill_in t("grammar.title"), with: data.title
      fill_in t("grammar.jregexp"), with: data.jregexp
      fill_in t("grammar.eregexp"), with: data.eregexp
      fill_in t("grammar.note"), with: data.note
      click_button t("save")

      expect(page).to have_title data.title

      expect(Grammar.count).to eq 2
      g = Grammar.last

      expect(g.ref).to eq data.ref
      expect(g.title).to eq data.title
      expect(g.note).to eq data.note
      expect(g.jregexp).to eq data.jregexp
      expect(g.eregexp).to eq data.eregexp
      expect(g.examples).to be_empty
      expect(g.last_example_checked).to eq 0
    end
  end

  context "failure" do
    it "no title" do
      click_link t("grammar.new")
      fill_in t("grammar.ref"), with: data.ref
      fill_in t("grammar.jregexp"), with: data.jregexp
      fill_in t("grammar.eregexp"), with: data.eregexp
      fill_in t("grammar.note"), with: data.note
      click_button t("save")

      expect(page).to have_title t("grammar.new")
      expect(Grammar.count).to eq 1
      expect_error(page, "blank")
    end
  end

  context "edit" do
    it "title" do
      click_link grammar.title
      click_link t("edit")

      expect(page).to have_title t("grammar.edit")

      fill_in t("grammar.title"), with: data.title
      click_button t("save")

      expect(page).to have_title data.title
      expect(Grammar.count).to eq 1
      g = Grammar.last
      expect(g.title).to eq data.title
    end
  end

  context "delete" do
    it "success" do
      expect(Grammar.count).to eq 1

      click_link grammar.title
      click_link t("edit")
      click_link t("delete")

      expect(page).to have_title t("grammar.grammar")
      expect(Grammar.count).to eq 0
    end
  end
end
