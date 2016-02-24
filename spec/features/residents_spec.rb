require 'rails_helper'

describe Resident do
  let(:data)      { build(:resident) }
  let!(:resident) { create(:resident) }

  before(:each) do
    login
    click_link t(:resident_residents)
  end

  context "create" do
    it "success" do
      click_link t(:resident_new)
      fill_in t(:person_first__names), with: data.first_names
      fill_in t(:person_last__name), with: data.last_name
      fill_in t(:email), with: data.email
      select data.block, from: t(:resident_block)
      select data.flat, from: t(:resident_flat)
      select data.bay, from: t(:resident_bay)
      click_button t(:save)

      expect(page).to have_title "#{data.first_names} #{data.last_name}"

      expect(Resident.count).to eq 2
      r = Resident.last

      expect(r.first_names).to eq data.first_names
      expect(r.last_name).to eq data.last_name
      expect(r.email).to eq data.email
      expect(r.block).to eq data.block
      expect(r.flat).to eq data.flat
      expect(r.bay).to eq data.bay
    end

    it "failure" do
      click_link t(:resident_new)
      fill_in t(:person_last__name), with: data.last_name
      fill_in t(:email), with: data.email
      select data.block, from: t(:resident_block)
      select data.flat, from: t(:resident_flat)
      select data.bay, from: t(:resident_bay)
      click_button t(:save)

      expect(page).to have_title t(:resident_new)
      expect(Resident.count).to eq 1
      expect(page).to have_css(error, text: "blank")
    end
  end

  context "edit" do
    it "success" do
      click_link resident.name
      click_link t(:edit)

      expect(page).to have_title t(:resident_edit)
      fill_in t(:person_first__names), with: data.first_names
      click_button t(:save)

      expect(Resident.count).to eq 1
      r = Resident.last

      expect(r.first_names).to eq data.first_names

      expect(page).to have_title r.name
    end

    it "failure" do
      click_link resident.name
      click_link t(:edit)

      fill_in t(:person_last__name), with: ""
      click_button t(:save)

      expect(page).to have_title t(:resident_edit)
      expect(page).to have_css(error, text: "blank")
    end
  end

  context "delete" do
    it "success" do
      expect(Resident.count).to eq 1

      click_link resident.name
      click_link t(:edit)
      click_link t(:delete)

      expect(page).to have_title t(:resident_residents)
      expect(Resident.count).to eq 0
    end
  end
end
