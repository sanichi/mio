require 'rails_helper'

describe Favourite do
  let(:data)       { build(:favourite) }
  let!(:favourite) { create(:favourite) }

  before(:each) do
    login
    click_link t(:favourite_favourites)
  end

  context "create" do
    it "success" do
      click_link t(:favourite_new)
      fill_in t(:name), with: data.name
      fill_in t(:year), with: data.year
      select t(:favourite_votes)[data.mark], from: t(:favourite_mark)
      select t(:favourite_votes)[data.sandra], from: t(:favourite_sandra)
      fill_in t(:favourite_link), with: data.link
      select t(:favourite_categories)[data.category], from: t(:favourite_category)
      click_button t(:save)

      expect(page).to have_title t(:favourite_favourites)

      expect(Favourite.count).to eq 2
      f = Favourite.last

      expect(f.name).to eq data.name
      expect(f.year).to eq data.year
      expect(f.mark).to eq data.mark
      expect(f.sandra).to eq data.sandra
      expect(f.link).to eq data.link
      expect(f.category).to eq data.category
    end

    it "failure" do
      click_link t(:favourite_new)
      fill_in t(:year), with: data.year
      select t(:favourite_votes)[data.mark], from: t(:favourite_mark)
      select t(:favourite_votes)[data.sandra], from: t(:favourite_sandra)
      select t(:favourite_categories)[data.category], from: t(:favourite_category)
      click_button t(:save)

      expect(page).to have_title t(:favourite_new)
      expect(Favourite.count).to eq 1
      expect(page).to have_css(error, text: "blank")
    end
  end

  context "edit" do
    it "success" do
      click_link t(:edit)

      expect(page).to have_title t(:favourite_edit)
      fill_in t(:name), with: data.name
      click_button t(:save)

      expect(page).to have_title t(:favourite_favourites)

      expect(Favourite.count).to eq 1
      f = Favourite.last

      expect(f.name).to eq data.name
    end

    it "failure" do
      click_link t(:edit)

      expect(page).to have_title t(:favourite_edit)
      select t(:favourite_votes)[0], from: t(:favourite_mark)
      select t(:favourite_votes)[0], from: t(:favourite_sandra)
      click_button t(:save)

      expect(page).to have_title t(:favourite_edit)
      expect(page).to have_css(error, text: "at least one vote")

      expect(Favourite.count).to eq 1
      f = Favourite.last

      expect(f.mark + f.sandra).to be > 0
    end
  end

  context "delete" do
    it "success" do
      expect(Favourite.count).to eq 1

      click_link t(:edit)
      click_link t(:delete)

      expect(page).to have_title t(:favourite_favourites)
      expect(Favourite.count).to eq 0
    end
  end
end
