require 'rails_helper'

describe Bay do
  let(:data)      { build(:bay) }
  let!(:resident) { create(:resident) }
  let!(:bay)      { create(:bay) }

  before(:each) do
    login
    click_link t(:bay_bays)
  end

  context "create" do
    it "success" do
      click_link t(:bay_new)
      fill_in t(:bay_number), with: data.number
      select resident.name, from: t(:bay_owner)
      click_button t(:save)

      expect(page).to have_title t(:bay_bay)

      expect(Bay.count).to eq 2
      b = Bay.last

      expect(b.number).to eq data.number
      expect(b.resident_id).to eq resident.id
    end

    it "failure" do
      click_link t(:bay_new)
      select resident.name, from: t(:bay_owner)
      click_button t(:save)

      expect(page).to have_title t(:bay_new)
      expect(Bay.count).to eq 1
      expect(page).to have_css(error, text: "not a number")
    end
  end

  context "edit" do
    it "success" do
      click_link bay.number
      click_link t(:edit)

      expect(page).to have_title t(:bay_edit)
      fill_in t(:bay_number), with: data.number
      click_button t(:save)

      expect(page).to have_title t(:bay_bay)

      expect(Bay.count).to eq 1
      b = Bay.last

      expect(b.number).to eq data.number
    end

    it "failure" do
      click_link bay.number
      click_link t(:edit)

      fill_in t(:bay_number), with: ""
      click_button t(:save)

      expect(page).to have_title t(:bay_edit)
      expect(page).to have_css(error, text: "not a number")
    end
  end

  context "delete" do
    it "success" do
      expect(Bay.count).to eq 1

      click_link bay.number
      click_link t(:edit)
      click_link t(:delete)

      expect(page).to have_title t(:bay_bays)
      expect(Bay.count).to eq 0
    end
  end
end
