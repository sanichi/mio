require 'rails_helper'

describe Place do
  let(:data)        { build(:place) }
  let!(:place)      { create(:place) }
  let!(:city)       { create(:place, category: "city", capital: false) }
  let!(:prefecture) { create(:place, category: "prefecture") }
  let!(:attraction) { create(:place, category: "attraction") }

  before(:each) do
    login
    click_link t("place.title")
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
      fill_in t("place.mark_position"), with: data.mark_position
      fill_in t("place.text_position"), with: data.text_position
      fill_in t("place.notes"), with: data.notes
      if data.capital
        check t("place.capital")
      else
        uncheck t("place.capital")
      end

      click_button t("save")

      expect(Place.count).to eq 5
      t = Place.by_created.last

      expect(page).to have_title data.jname

      expect(t.jname).to eq data.jname
      expect(t.ename).to eq data.ename
      expect(t.reading).to eq data.reading
      expect(t.wiki).to eq data.wiki
      expect(t.pop).to eq data.pop
      expect(t.category).to eq data.category
      expect(t.vbox).to eq data.vbox
      expect(t.mark_position).to eq data.mark_position
      expect(t.text_position).to eq data.text_position
      expect(t.capital).to eq data.capital
      expect(t.notes).to eq data.notes
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
      fill_in t("place.mark_position"), with: data.mark_position
      fill_in t("place.text_position"), with: data.text_position
      fill_in t("place.notes"), with: data.notes
      if data.capital
        check t("place.capital")
      else
        uncheck t("place.capital")
      end

      click_button t("save")

      expect(page).to have_title t("place.new")
      expect(Place.count).to eq 4
      expect_error(page, "blank")
    end
  end

  context "edit" do
    it "jname" do
      visit place_path(place)
      click_link t("edit")

      expect(page).to have_title t("place.edit")
      fill_in t("place.jname"), with: data.jname
      click_button t("save")

      expect(page).to have_title data.jname

      place.reload
      expect(place.jname).to eq data.jname
    end

    it "capital" do
      expect(city.capital).to be(false)

      visit place_path(city)
      click_link t("edit")

      expect(page).to have_title t("place.edit")
      check t("place.capital")
      click_button t("save")

      expect(page).to have_title city.jname

      city.reload
      expect(city.capital).to be(true)
    end

    it "capital error" do
      expect(prefecture.capital).to be(false)

      visit place_path(prefecture)
      click_link t("edit")

      expect(page).to have_title t("place.edit")
      check t("place.capital")
      click_button t("save")

      expect(page).to have_title t("place.edit")
      expect_error(page, "only cities")

      prefecture.reload
      expect(prefecture.capital).to be false
    end
  end

  context "delete" do
    it "success" do
      expect(Place.count).to eq 4

      visit place_path(place)
      click_link t("edit")
      click_link t("delete")

      expect(page).to have_title t("place.title")
      expect(Place.count).to eq 3
    end
  end
end
