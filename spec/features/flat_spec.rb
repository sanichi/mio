require 'rails_helper'

describe Flat do
  let(:data)      { build(:flat) }
  let!(:flat)     { create(:flat) }
  let!(:owner)    { create(:resident) }
  let!(:tenant)   { create(:resident) }
  let!(:landlord) { create(:resident) }
  let!(:resident) { create(:resident) }
  let(:flat2)     { create(:flat) }

  before(:each) do
    login
    click_link t(:flat_flats)
  end

  context "create" do
    it "success" do
      click_link t(:flat_new)
      select data.building, from: t(:flat_building)
      select data.number, from: t(:flat_number)
      select data.block, from: t(:flat_block)
      select data.bay, from: t(:flat_bay)
      select data.category, from: t(:flat_category)
      select data.name, from: t(:flat_name)
      select owner.name, from: t(:flat_owner)
      click_button t(:save)

      expect(page).to have_title t(:flat_flat)

      expect(Flat.count).to eq 2
      f = Flat.last

      expect(f.building).to eq data.building
      expect(f.number).to eq data.number
      expect(f.block).to eq data.block
      expect(f.bay).to eq data.bay
      expect(f.category).to eq data.category
      expect(f.name).to eq data.name
      expect(f.owner_id).to eq owner.id
      expect(f.tenant_id).to be_nil
      expect(f.landlord_id).to be_nil
    end

    it "failure" do
      click_link t(:flat_new)
      select data.block, from: t(:flat_block)
      select data.bay, from: t(:flat_bay)
      select data.category, from: t(:flat_category)
      select data.name, from: t(:flat_name)
      click_button t(:save)

      expect(page).to have_title t(:flat_new)
      expect(Flat.count).to eq 1
      expect(page).to have_css(error, text: "not included")
    end
  end

  context "edit" do
    it "success" do
      click_link flat.address
      click_link t(:edit)

      expect(page).to have_title t(:flat_edit)

      select data.number, from: t(:flat_number)
      click_button t(:save)

      expect(page).to have_title t(:flat_flat)

      expect(Flat.count).to eq 1
      f = Flat.last

      expect(f.number).to eq data.number
    end

    it "failure (duplicate bay)" do
      click_link flat.address
      click_link t(:edit)

      select flat2.bay, from: t(:flat_bay)
      click_button t(:save)

      expect(page).to have_title t(:flat_edit)
      expect(page).to have_css(error, text: "already been taken")
    end

    it "failure (tenant is owner)" do
      click_link flat.address
      click_link t(:edit)

      select resident.name, from: t(:flat_owner)
      select resident.name, from: t(:flat_tenant)
      click_button t(:save)

      expect(page).to have_title t(:flat_edit)
      expect(page).to have_css(error, text: "can only have one")
    end
  end

  context "delete" do
    it "success" do
      expect(Flat.count).to eq 1

      click_link flat.address
      click_link t(:edit)
      click_link t(:delete)

      expect(page).to have_title t(:flat_flats)
      expect(Flat.count).to eq 0
    end
  end
end
