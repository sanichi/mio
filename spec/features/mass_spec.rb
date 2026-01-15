require 'rails_helper'

describe Mass, js: true do
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
      fill_in t("mass.start_2"), with: data.start_2
      fill_in t("mass.finish_2"), with: data.finish_2
      click_button t("save")

      expect(page).to have_title t("mass.title")

      expect(Mass.count).to eq 1
      m = Mass.first

      expect(m.date).to eq data.date
      expect(m.start).to eq data.start
      expect(m.finish).to eq data.finish
      expect(m.start_2).to eq data.start_2
      expect(m.finish_2).to eq data.finish_2
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

        expect(page).to have_title t("mass.title")
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
      click_link t("symbol.edit")

      expect(page).to have_title t("mass.edit")
      fill_in t("mass.start"), with: data.start + 10
      fill_in t("mass.finish"), with: ""
      fill_in t("mass.start_2"), with: data.start_2 + 5
      click_button t("save")

      expect(page).to have_title t("mass.title")

      expect(Mass.count).to eq 1
      m = Mass.first

      expect(m.date).to eq data.date
      expect(m.start).to eq data.start + 10
      expect(m.finish).to be_nil
      expect(m.start_2).to eq data.start_2 + 5
    end
  end

  context "delete" do
    let!(:mass) { create(:mass) }

    it "success" do
      visit masses_path
      click_link t("symbol.edit")
      accept_confirm do
        click_link t("delete")
      end

      expect(page).to have_title t("mass.title")
      expect(Mass.count).to eq 0
    end
  end
end
