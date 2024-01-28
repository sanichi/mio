require 'rails_helper'

describe Constellation do
  let(:data) { build(:constellation) }
  let!(:constellation) { create(:constellation) }

  before(:each) do
    login
    click_link t("constellation.constellations")
  end

  context "create" do
    it "success" do
      click_link t("constellation.new")
      fill_in t("constellation.name"), with: data.name
      fill_in t("constellation.iau"), with: data.iau
      fill_in t("constellation.wikipedia"), with: data.wikipedia
      fill_in t("constellation.note"), with: data.note

      click_button t("save")

      expect(Constellation.count).to eq 2
      c = Constellation.order(:created_at).last

      expect(page).to have_title data.name

      expect(c.name).to eq data.name
      expect(c.iau).to eq data.iau
      expect(c.wikipedia).to eq data.wikipedia
      expect(c.note).to eq data.note
    end

    context "failure" do
      it "missing iau" do
        click_link t("constellation.new")
        fill_in t("constellation.name"), with: data.name
        fill_in t("constellation.wikipedia"), with: data.wikipedia
        fill_in t("constellation.note"), with: data.note
        click_button t("save")

        expect(page).to have_title t("constellation.new")
        expect(Constellation.count).to eq 1
        expect_error(page, "Iau can't be blank")
      end

      it "duplicate name" do
        click_link t("constellation.new")
        fill_in t("constellation.name"), with: constellation.name
        fill_in t("constellation.iau"), with: data.iau
        fill_in t("constellation.wikipedia"), with: data.wikipedia
        fill_in t("constellation.note"), with: data.note

        click_button t("save")

        expect(page).to have_title t("constellation.new")
        expect(Constellation.count).to eq 1
        expect_error(page, "Name has already been taken")
      end
    end
  end

  context "edit" do
    it "success" do
      visit constellation_path(constellation)
      click_link t("edit")

      expect(page).to have_title t("constellation.edit")
      fill_in t("constellation.name"), with: data.name
      click_button t("save")

      expect(page).to have_title data.name

      expect(Constellation.count).to eq 1
      c = Constellation.last

      expect(c.name).to eq data.name
    end
  end

  context "delete" do
    it "success" do
      expect(Constellation.count).to eq 1

      visit constellation_path(constellation)
      click_link t("edit")
      click_link t("delete")

      expect(page).to have_title t("constellation.constellations")
      expect(Constellation.count).to eq 0
    end
  end
end
