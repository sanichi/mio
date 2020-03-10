require 'rails_helper'

describe Tutorial do
  let(:data) { build(:tutorial) }
  let!(:tutorial) { create(:tutorial) }

  before(:each) do
    login
    click_link t("tutorial.tutorials")
  end

  context "create" do
    it "success" do
      click_link t("tutorial.new")
      fill_in t("date"), with: data.date
      fill_in t("tutorial.summary"), with: data.summary
      fill_in t("tutorial.notes"), with: data.notes
      data.draft ? check(t("tutorial.draft")) : uncheck(t("tutorial.draft"))

      click_button t("save")

      expect(Tutorial.count).to eq 2
      t = Tutorial.by_created.last

      expect(page).to have_title t("tutorial.title", number: t.number)

      expect(t.date).to eq data.date
      expect(t.notes).to eq data.notes
      expect(t.summary).to eq data.summary
      expect(t.draft).to eq data.draft
    end

    it "failure" do
      click_link t("tutorial.new")
      fill_in t("date"), with: data.date
      fill_in t("tutorial.notes"), with: data.notes
      data.draft ? check(t("tutorial.draft")) : uncheck(t("tutorial.draft"))
      click_button t("save")

      expect(page).to have_title t("tutorial.new")
      expect(Tutorial.count).to eq 1
      expect_error(page, "blank")
    end
  end

  context "edit" do
    it "success" do
      visit tutorial_path(tutorial)
      click_link t("edit")

      expect(page).to have_title t("tutorial.edit")
      fill_in t("tutorial.summary"), with: data.summary
      click_button t("save")

      expect(page).to have_title t("tutorial.title", number: 1)

      expect(Tutorial.count).to eq 1
      t = Tutorial.last

      expect(t.summary).to eq data.summary
    end
  end

  context "delete" do
    it "success" do
      expect(Tutorial.count).to eq 1

      visit tutorial_path(tutorial)
      click_link t("edit")
      click_link t("delete")

      expect(page).to have_title t("tutorial.tutorials")
      expect(Tutorial.count).to eq 0
    end
  end
end
