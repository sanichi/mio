require 'rails_helper'

describe Mass do
  before(:each) do
    login
    visit masses_path
  end

  context "create" do
    let(:data)  { build(:mass) }

    it "success" do
      click_link t("mass.new")
      fill_in t("mass.date"), with: data.date
      fill_in t("mass.start"), with: data.start
      fill_in t("mass.finish"), with: data.finish
      click_button t("save")

      expect(page).to have_title t("mass.data")

      expect(Mass.count).to eq 1
      m = Mass.first

      expect(m.date).to eq data.date
      expect(m.start).to eq data.start
      expect(m.finish).to eq data.finish
    end

    context "failure" do
      it "not enough" do
        click_link t("mass.new")
        fill_in t("mass.date"), with: data.date
        click_button t("save")

        expect(page).to have_title t("mass.new")
        expect(Mass.count).to eq 0
        expect_error(page, "at least 1")
      end

      it "out of range" do
        click_link t("mass.new")
        fill_in t("mass.date"), with: data.date
        fill_in t("mass.start"), with: data.start
        fill_in t("mass.finish"), with: Mass::MAX_KG + 10
        click_button t("save")

        expect(page).to have_title t("mass.new")
        expect(Mass.count).to eq 0
        expect_error(page, "must be less than")
      end

      it "no date" do
        click_link t("mass.new")
        fill_in t("mass.date"), with: ""
        fill_in t("mass.start"), with: data.start
        fill_in t("mass.finish"), with: data.finish
        click_button t("save")

        expect(page).to have_title t("mass.new")
        expect(Mass.count).to eq 0
        expect_error(page, "can't be blank")
      end

      it "duplicate date" do
        click_link t("mass.new")
        fill_in t("mass.date"), with: data.date
        fill_in t("mass.start"), with: data.start
        fill_in t("mass.finish"), with: data.finish
        click_button t("save")

        expect(page).to have_title t("mass.data")
        expect(Mass.count).to eq 1

        click_link t("mass.new")
        fill_in t("mass.date"), with: data.date
        fill_in t("mass.start"), with: data.start
        fill_in t("mass.finish"), with: data.finish
        click_button t("save")

        expect(page).to have_title t("mass.new")
        expect(Mass.count).to eq 1
        expect_error(page, "has already been taken")
      end
    end
  end

  context "edit" do
    let(:data)  { build(:mass) }
    let!(:mass) { create(:mass) }

    it "success" do
      visit masses_path
      click_link t("edit")

      expect(page).to have_title t("mass.edit")
      fill_in t("mass.start"), with: data.start + 10
      fill_in t("mass.finish"), with: ""
      click_button t("save")

      expect(page).to have_title t("mass.data")

      expect(Mass.count).to eq 1
      m = Mass.first

      expect(m.date).to eq data.date
      expect(m.start).to eq data.start + 10
      expect(m.finish).to be_nil
    end
  end

  context "delete" do
    let!(:mass) { create(:mass) }

    it "success" do
      visit masses_path
      click_link t("edit")
      click_link t("delete")

      expect(page).to have_title t("mass.data")
      expect(Mass.count).to eq 0
    end
  end
end
