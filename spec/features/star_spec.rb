require 'rails_helper'

describe Star do
  let(:data) { build(:star) }
  let!(:star) { create(:star) }

  before(:each) do
    login
    click_link t("star.stars")
  end

  context "create" do
    it "success" do
      click_link t("star.new")
      fill_in t("star.name"), with: data.name
      fill_in t("star.distance"), with: data.distance
      fill_in t("star.note"), with: data.note

      click_button t("save")

      expect(Star.count).to eq 2
      s = Star.order(:created_at).last

      expect(page).to have_title data.name

      expect(s.name).to eq data.name
      expect(s.distance).to eq data.distance
      expect(s.note).to eq data.note
    end

    it "failure" do
      click_link t("star.new")
      fill_in t("star.name"), with: data.name
      fill_in t("star.note"), with: data.note
      click_button t("save")

      expect(page).to have_title t("star.new")
      expect(Star.count).to eq 1
      expect_error(page, "not a number")
    end
  end

  context "edit" do
    it "success" do
      visit star_path(star)
      click_link t("edit")

      expect(page).to have_title t("star.edit")
      fill_in t("star.name"), with: data.name
      click_button t("save")

      expect(page).to have_title data.name

      expect(Star.count).to eq 1
      s = Star.last

      expect(s.name).to eq data.name
    end
  end

  context "delete" do
    it "success" do
      expect(Star.count).to eq 1

      visit star_path(star)
      click_link t("edit")
      click_link t("delete")

      expect(page).to have_title t("star.stars")
      expect(Star.count).to eq 0
    end
  end
end
