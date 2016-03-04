require 'rails_helper'

describe Vehicle do
  let(:data)      { build(:vehicle) }
  let!(:resident) { create(:resident) }
  let!(:vehicle)  { create(:vehicle) }

  before(:each) do
    login
    click_link t(:vehicle_vehicles)
  end

  context "create" do
    it "success" do
      click_link t(:vehicle_new)
      fill_in t(:vehicle_registration), with: data.registration
      fill_in t(:description), with: data.description
      select resident.name, from: t(:owner)
      click_button t(:save)

      expect(page).to have_title t(:vehicle_vehicle)

      expect(Vehicle.count).to eq 2
      v = Vehicle.last

      expect(v.registration).to eq data.registration
      expect(v.description).to eq data.description
      expect(v.resident_id).to eq resident.id
    end

    it "failure" do
      click_link t(:vehicle_new)
      fill_in t(:description), with: data.description
      select resident.name, from: t(:owner)
      click_button t(:save)

      expect(page).to have_title t(:vehicle_new)
      expect(Vehicle.count).to eq 1
      expect(page).to have_css(error, text: "blank")
    end
  end

  context "edit" do
    it "success" do
      click_link vehicle.registration
      click_link t(:edit)

      expect(page).to have_title t(:vehicle_edit)
      fill_in t(:vehicle_registration), with: data.registration
      click_button t(:save)

      expect(page).to have_title t(:vehicle_vehicle)

      expect(Vehicle.count).to eq 1
      v = Vehicle.last

      expect(v.registration).to eq data.registration
    end

    it "failure" do
      click_link vehicle.registration
      click_link t(:edit)

      fill_in t(:description), with: ""
      click_button t(:save)

      expect(page).to have_title t(:vehicle_edit)
      expect(page).to have_css(error, text: "blank")
    end
  end

  context "delete" do
    it "success" do
      expect(Vehicle.count).to eq 1

      click_link vehicle.registration
      click_link t(:edit)
      click_link t(:delete)

      expect(page).to have_title t(:vehicle_vehicles)
      expect(Vehicle.count).to eq 0
    end
  end
end
