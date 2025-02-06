require 'rails_helper'

describe Favourite, js: true do
  let(:data)       { build(:favourite) }
  let!(:favourite) { create(:favourite) }

  before(:each) do
    login
    click_link t("home") # currently favourites are on the home page
  end

  context "create" do
    it "success" do
      click_link t("favourite.new")
      fill_in t("name"), with: data.name
      fill_in t("year"), with: data.year
      select data.mark.to_s, from: t("favourite.mark")
      select data.sandra.to_s, from: t("favourite.sandra")
      fill_in t("favourite.link"), with: data.link
      select t("favourite.categories")[data.category], from: t("favourite.category")
      fill_in t("favourite.note"), with: data.note
      click_button t("save")

      expect(page).to have_title data.name

      expect(Favourite.count).to eq 2
      f = Favourite.last

      expect(f.name).to eq data.name
      expect(f.note).to eq data.note
      expect(f.year).to eq data.year
      expect(f.mark).to eq data.mark
      expect(f.sandra).to eq data.sandra
      expect(f.link).to eq data.link
      expect(f.category).to eq data.category
    end

    it "failure" do
      click_link t("favourite.new")
      fill_in t("year"), with: data.year
      select data.mark.to_s, from: t("favourite.mark")
      select data.sandra.to_s, from: t("favourite.sandra")
      fill_in t("favourite.link"), with: data.link
      select t("favourite.categories")[data.category], from: t("favourite.category")
      fill_in t("favourite.note"), with: data.note
      click_button t("save")

      expect(page).to have_title t("favourite.new")
      expect(Favourite.count).to eq 1
      expect_error(page, "blank")
    end
  end

  context "edit" do
    it "success" do
      click_link favourite.name
      click_link t("edit")

      expect(page).to have_title t("favourite.edit")
      fill_in t("name"), with: data.name
      click_button t("save")

      expect(page).to have_title data.name

      f = Favourite.last
      expect(f.name).to eq data.name
    end

    it "failure" do
      click_link favourite.name
      click_link t("edit")

      expect(page).to have_title t("favourite.edit")
      select t("favourite.not_applicable"), from: t("favourite.mark")
      select t("favourite.not_applicable"), from: t("favourite.sandra")
      click_button t("save")

      expect(page).to have_title t("favourite.edit")
      expect_error(page, "at least one")

      f = Favourite.last
      expect(f.mark + f.sandra).to be > 0
    end
  end

  context "delete" do
    it "success" do
      expect(Favourite.count).to eq 1

      click_link favourite.name
      click_link t("edit")
      accept_confirm do
        click_link t("delete")
      end

      expect(page).to have_title t("favourite.title")
      expect(Favourite.count).to eq 0
    end
  end
end
