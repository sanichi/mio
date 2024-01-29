require 'rails_helper'

describe Star do
  let(:data) { build(:star) }
  let!(:star) { create(:star) }

  before(:each) do
    login
    data.constellation.save!
    click_link t("star.stars")
  end

  context "create" do
    it "success" do
      click_link t("star.new")
      select data.constellation.name, from: t("star.constellation")
      fill_in t("star.alpha"), with: data.alpha
      fill_in t("star.bayer"), with: data.bayer
      fill_in t("star.components"), with: data.components
      fill_in t("star.delta"), with: data.delta
      fill_in t("star.distance"), with: data.distance
      fill_in t("star.luminosity"), with: data.luminosity
      fill_in t("star.magnitude"), with: data.magnitude
      fill_in t("star.mass"), with: data.mass
      fill_in t("star.name"), with: data.name
      fill_in t("star.note"), with: data.note
      fill_in t("star.radius"), with: data.radius
      fill_in t("star.temperature"), with: data.temperature
      fill_in t("star.wikipedia"), with: data.wikipedia

      click_button t("save")

      expect(Star.count).to eq 2
      s = Star.order(:created_at).last

      expect(page).to have_title data.name

      expect(s.alpha).to eq data.alpha
      expect(s.bayer).to eq data.bayer
      expect(s.components).to eq data.components
      expect(s.constellation).to eq data.constellation
      expect(s.constellation.stars_count).to eq 1
      expect(s.delta).to eq data.delta
      expect(s.distance).to eq data.distance
      expect(s.luminosity).to eq data.luminosity
      expect(s.magnitude).to eq data.magnitude
      expect(s.mass).to eq data.mass
      expect(s.name).to eq data.name
      expect(s.note).to eq data.note
      expect(s.radius).to eq data.radius
      expect(s.wikipedia).to eq data.wikipedia
    end

    context "failure" do
      it "missing distance" do
        click_link t("star.new")
        select data.constellation.name, from: t("star.constellation")
        fill_in t("star.alpha"), with: data.alpha
        fill_in t("star.bayer"), with: data.bayer
        fill_in t("star.components"), with: data.components
        fill_in t("star.delta"), with: data.delta
        fill_in t("star.luminosity"), with: data.luminosity
        fill_in t("star.magnitude"), with: data.magnitude
        fill_in t("star.mass"), with: data.mass
        fill_in t("star.name"), with: data.name
        fill_in t("star.note"), with: data.note
        fill_in t("star.radius"), with: data.radius
        fill_in t("star.temperature"), with: data.temperature
        fill_in t("star.wikipedia"), with: data.wikipedia
        click_button t("save")

        expect(page).to have_title t("star.new")
        expect(Star.count).to eq 1
        expect_error(page, "Distance is not a number")
      end

      it "invalid delta" do
        click_link t("star.new")
        select data.constellation.name, from: t("star.constellation")
        fill_in t("star.alpha"), with: "240000"
        fill_in t("star.bayer"), with: data.bayer
        fill_in t("star.components"), with: data.components
        fill_in t("star.delta"), with: data.delta
        fill_in t("star.distance"), with: data.distance
        fill_in t("star.luminosity"), with: data.luminosity
        fill_in t("star.magnitude"), with: data.magnitude
        fill_in t("star.mass"), with: data.mass
        fill_in t("star.name"), with: data.name
        fill_in t("star.note"), with: data.note
        fill_in t("star.radius"), with: data.radius
        fill_in t("star.temperature"), with: data.temperature
        fill_in t("star.wikipedia"), with: data.wikipedia
        click_button t("save")

        expect(page).to have_title t("star.new")
        expect(Star.count).to eq 1
        expect_error(page, "Alpha is invalid")
      end

      it "duplicate name" do
        click_link t("star.new")
        select data.constellation.name, from: t("star.constellation")
        fill_in t("star.alpha"), with: data.alpha
        fill_in t("star.bayer"), with: data.bayer
        fill_in t("star.components"), with: data.components
        fill_in t("star.delta"), with: data.delta
        fill_in t("star.distance"), with: data.distance
        fill_in t("star.luminosity"), with: data.luminosity
        fill_in t("star.magnitude"), with: data.magnitude
        fill_in t("star.mass"), with: data.mass
        fill_in t("star.name"), with: star.name
        fill_in t("star.note"), with: data.note
        fill_in t("star.radius"), with: data.radius
        fill_in t("star.temperature"), with: data.temperature
        fill_in t("star.wikipedia"), with: data.wikipedia

        click_button t("save")

        expect(page).to have_title t("star.new")
        expect(Star.count).to eq 1
        expect_error(page, "Name has already been taken")
      end

      it "duplicate bayer" do
        click_link t("star.new")
        select star.constellation.name, from: t("star.constellation")
        fill_in t("star.alpha"), with: data.alpha
        fill_in t("star.bayer"), with: star.bayer
        fill_in t("star.components"), with: data.components
        fill_in t("star.delta"), with: data.delta
        fill_in t("star.distance"), with: data.distance
        fill_in t("star.luminosity"), with: data.luminosity
        fill_in t("star.magnitude"), with: data.magnitude
        fill_in t("star.mass"), with: data.mass
        fill_in t("star.name"), with: data.name
        fill_in t("star.note"), with: data.note
        fill_in t("star.radius"), with: data.radius
        fill_in t("star.temperature"), with: data.temperature
        fill_in t("star.wikipedia"), with: data.wikipedia

        click_button t("save")

        expect(page).to have_title t("star.new")
        expect(Star.count).to eq 1
        expect_error(page, "Bayer has already been taken")
      end
    end
  end

  context "edit" do
    it "success" do
      oldc = star.constellation
      expect(oldc.stars_count).to eq 1

      visit star_path(star)
      click_link t("edit")

      expect(page).to have_title t("star.edit")
      select data.constellation.name, from: t("star.constellation")
      fill_in t("star.alpha"), with: data.alpha
      fill_in t("star.bayer"), with: data.bayer
      fill_in t("star.delta"), with: data.delta
      fill_in t("star.magnitude"), with: data.magnitude
      fill_in t("star.name"), with: data.name
      click_button t("save")

      expect(page).to have_title data.name

      expect(Star.count).to eq 1
      s = Star.last

      expect(s.name).to eq data.name
      expect(s.constellation).to eq data.constellation
      expect(s.constellation.stars_count).to eq 1
      expect(s.bayer).to eq data.bayer
      expect(s.magnitude).to eq data.magnitude
      expect(s.alpha).to eq data.alpha
      expect(s.delta).to eq data.delta

      oldc.reload
      expect(oldc.stars_count).to eq 0
    end
  end

  context "delete" do
    it "success" do
      expect(Star.count).to eq 1

      oldc = star.constellation
      expect(oldc.stars_count).to eq 1

      visit star_path(star)
      click_link t("edit")
      click_link t("delete")

      expect(page).to have_title t("star.stars")
      expect(Star.count).to eq 0

      oldc.reload
      expect(oldc.stars_count).to eq 0
    end
  end
end
