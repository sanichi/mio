require 'rails_helper'

describe Parking do
  let!(:parking)  { create(:parking) }
  let!(:vehicle)  { create(:vehicle) }
  let!(:flat)     { create(:flat) }

  before(:each) do
    login
    click_link t("parking.parkings")
  end

  context "create" do
    it "success" do
      click_link t("parking.new")
      select vehicle.registration, from: t("vehicle.vehicle")
      select flat.bay.to_s, from: t("flat.bay")
      click_button t("save")

      expect(page).to have_title t("parking.parkings")

      expect(Parking.count).to eq 2
      p = Parking.last

      expect(p.vehicle_id).to eq vehicle.id
      expect(p.bay).to eq flat.bay
      expect(p.noted_at.to_i).to be_within(1).of(Time.now.to_i)
    end

    it "failure (no bay)" do
      click_link t("parking.new")
      select vehicle.registration, from: t("vehicle.vehicle")
      click_button t("save")

      expect(page).to have_title t("parking.new")
      expect(page).to have_css(error, text: "not a number")

      expect(Parking.count).to eq 1
    end

    it "failure (invalid time)" do
      click_link t("parking.new")
      select vehicle.registration, from: t("vehicle.vehicle")
      select flat.bay.to_s, from: t("flat.bay")
      fill_in t("parking.noted_at"), with: "tomorrow at 3pm"
      click_button t("save")

      expect(page).to have_title t("parking.new")
      expect(page).to have_css(error, text: "future")

      expect(Parking.count).to eq 1
    end
  end

  context "delete" do
    it "success" do
      expect(Parking.count).to eq 1

      click_link t("symbol.cross")

      expect(page).to have_title t("parking.parkings")
      expect(Parking.count).to eq 0
    end
  end
end
