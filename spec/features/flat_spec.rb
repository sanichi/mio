require 'rails_helper'

describe Flat do
  let(:data)      { build(:flat) }
  let!(:flat)     { create(:flat) }
  let!(:owner)    { create(:resident) }
  let!(:tenant)   { create(:resident) }
  let!(:landlord) { create(:resident) }
  let(:flat2)     { create(:flat) }

  before(:each) do
    login
    click_link t("flat.flats")
  end

  context "create" do
    context "success" do
      it "maximum" do
        click_link t("flat.new")
        select data.building.to_s, from: t("flat.building")
        select data.number.to_s, from: t("flat.number")
        select data.block.to_s, from: t("flat.block")
        select data.bay.to_s, from: t("flat.bay")
        select data.category, from: t("flat.category")
        select data.name, from: t("flat.name")
        select tenant.name, from: t("flat.tenant")
        select landlord.name, from: t("flat.landlord")
        fill_in t("notes"), with: data.notes
        click_button t("save")

        expect(page).to have_title t("flat.flat")

        expect(Flat.count).to eq 2
        f = Flat.last

        expect(f.building).to eq data.building
        expect(f.number).to eq data.number
        expect(f.block).to eq data.block
        expect(f.bay).to eq data.bay
        expect(f.category).to eq data.category
        expect(f.name).to eq data.name
        expect(f.notes).to eq data.notes
        expect(f.owner_id).to be_nil
        expect(f.tenant_id).to eq tenant.id
        expect(f.landlord_id).to eq landlord.id
      end

      it "minimum" do
        click_link t("flat.new")
        select data.building.to_s, from: t("flat.building")
        select t("none"), from: t("flat.number")
        select data.block.to_s, from: t("flat.block")
        select t("none"), from: t("flat.bay")
        select data.category, from: t("flat.category")
        select data.name, from: t("flat.name")
        click_button t("save")

        expect(page).to have_title t("flat.flat")

        expect(Flat.count).to eq 2
        f = Flat.last

        expect(f.building).to eq data.building
        expect(f.number).to be_nil
        expect(f.block).to eq data.block
        expect(f.bay).to be_nil
        expect(f.category).to eq data.category
        expect(f.name).to eq data.name
        expect(f.notes).to be_nil
        expect(f.owner_id).to be_nil
        expect(f.tenant_id).to be_nil
        expect(f.landlord_id).to be_nil
      end
    end

    context "failure" do
      it "no building" do
        click_link t("flat.new")
        select data.block.to_s, from: t("flat.block")
        select data.bay.to_s, from: t("flat.bay")
        select data.category, from: t("flat.category")
        select data.name, from: t("flat.name")
        click_button t("save")

        expect(page).to have_title t("flat.new")
        expect(Flat.count).to eq 1
        expect(page).to have_css(error, text: "not included")
      end
    end
  end

  context "edit" do
    context "success" do
      it "flat" do
        click_link flat.address
        click_link t("edit")

        expect(page).to have_title t("flat.edit")

        select data.number.to_s, from: t("flat.number")
        click_button t("save")

        expect(page).to have_title t("flat.flat")

        expect(Flat.count).to eq 1
        f = Flat.last

        expect(f.number).to eq data.number
      end
    end

    context "failure" do
      it "duplicate bay" do
        click_link flat.address
        click_link t("edit")

        select flat2.bay.to_s, from: t("flat.bay")
        click_button t("save")

        expect(page).to have_title t("flat.edit")
        expect(page).to have_css(error, text: "already been taken")
      end

      it "owner with tenant" do
        click_link flat.address
        click_link t("edit")

        select owner.name, from: t("flat.owner")
        select tenant.name, from: t("flat.tenant")
        click_button t("save")

        expect(page).to have_title t("flat.edit")
        expect(page).to have_css(error, text: "can't have")
      end

      it "owner with landlord" do
        click_link flat.address
        click_link t("edit")

        select owner.name, from: t("flat.owner")
        select landlord.name, from: t("flat.landlord")
        click_button t("save")

        expect(page).to have_title t("flat.edit")
        expect(page).to have_css(error, text: "can't have")
      end
    end
  end

  context "delete" do
    it "success" do
      expect(Flat.count).to eq 1

      click_link flat.address
      click_link t("edit")
      click_link t("delete")

      expect(page).to have_title t("flat.flats")
      expect(Flat.count).to eq 0
    end
  end
end
