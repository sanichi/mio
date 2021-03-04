require 'rails_helper'

describe Place do
  let(:data) { build(:place) }
  let!(:place) { create(:place) }

  before(:each) do
    login
    click_link t("place.places")
  end

  context "create" do
    it "success" do
      click_link t("place.new")
      fill_in t("place.jname"), with: data.jname
      fill_in t("place.reading"), with: data.reading
      fill_in t("place.ename"), with: data.ename
      fill_in t("place.wiki"), with: data.wiki
      fill_in t("place.pop"), with: data.pop
      select t("place.categories.#{data.category}"), from: t("place.category")
      fill_in t("place.vbox"), with: data.vbox

      click_button t("save")

      expect(Place.count).to eq 2
      t = Place.by_created.last

      expect(page).to have_title data.jname

      expect(t.jname).to eq data.jname
      expect(t.ename).to eq data.ename
      expect(t.reading).to eq data.reading
      expect(t.wiki).to eq data.wiki
      expect(t.pop).to eq data.pop
      expect(t.category).to eq data.category
      expect(t.vbox).to eq data.vbox
    end

    it "failure" do
      click_link t("place.new")
      fill_in t("place.jname"), with: data.jname
      fill_in t("place.reading"), with: data.reading
      fill_in t("place.ename"), with: data.ename
      # fill_in t("place.wiki"), with: data.wiki
      fill_in t("place.pop"), with: data.pop
      select t("place.categories.#{data.category}"), from: t("place.category")
      fill_in t("place.vbox"), with: data.vbox

      click_button t("save")

      expect(page).to have_title t("place.new")
      expect(Place.count).to eq 1
      expect_error(page, "blank")
    end
  end

  context "edit" do
    it "success" do
      visit place_path(place)
      click_link t("edit")

      expect(page).to have_title t("place.edit")
      fill_in t("place.jname"), with: data.jname
      click_button t("save")

      expect(page).to have_title data.jname

      expect(Place.count).to eq 1
      t = Place.by_created.last

      expect(t.jname).to eq data.jname
    end
  end

  context "delete" do
    it "success" do
      expect(Place.count).to eq 1

      visit place_path(place)
      click_link t("edit")
      click_link t("delete")

      expect(page).to have_title t("place.places")
      expect(Place.count).to eq 0
    end
  end
end
