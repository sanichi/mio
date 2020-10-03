require 'rails_helper'

describe Misa do
  let(:data)  { build(:misa) }
  let!(:misa) { create(:misa) }

  before(:each) do
    login
    click_link t("misa.misas")
  end

  context "create" do
    it "success" do
      click_link t("misa.new")
      if data.alt
        fill_in t("misa.alt"), with: data.alt
      end
      data.japanese ? check(:misa_japanese) : uncheck(:misa_japanese)
      fill_in t("misa.minutes"), with: data.minutes
      fill_in t("misa.note"), with: data.note
      fill_in t("misa.published"), with: data.published
      fill_in t("misa.title"), with: data.title
      fill_in t("misa.url"), with: data.url
      fill_in t("misa.series"), with: data.series
      fill_in t("misa.number"), with: data.number
      click_button t("save")

      expect(page).to have_title t("misa.misa")

      expect(Misa.count).to eq 2
      m = Misa.last

      expect(m.alt).to eq data.alt
      expect(m.japanese).to eq data.japanese
      expect(m.minutes).to eq data.minutes
      expect(m.note).to eq data.note
      expect(m.published).to eq data.published
      expect(m.title).to eq data.title
      expect(m.url).to eq data.url
      if data.series
        expect(m.series).to eq data.series
        expect(m.number).to eq data.number
      else
        expect(m.series).to be_nil
        expect(m.number).to be_nil
      end
    end

    it "failure" do
      click_link t("misa.new")
      if data.alt
        fill_in t("misa.alt"), with: data.alt
      end
      data.japanese ? check(:misa_japanese) : uncheck(:misa_japanese)
      fill_in t("misa.minutes"), with: data.minutes
      fill_in t("misa.note"), with: data.note
      # fill_in t("misa.title"), with: data.title
      fill_in t("misa.published"), with: data.published
      fill_in t("misa.url"), with: data.url
      fill_in t("misa.series"), with: data.series
      fill_in t("misa.number"), with: data.number
      click_button t("save")

      expect(page).to have_title t("misa.new")
      expect(Misa.count).to eq 1
      expect_error(page, "blank")
    end
  end

  context "edit" do
    it "success" do
      visit misa_path(misa)
      click_link t("edit")

      expect(page).to have_title t("misa.edit")
      fill_in t("misa.title"), with: data.title
      click_button t("save")

      expect(page).to have_title t("misa.misa")

      expect(Misa.count).to eq 1
      m = Misa.last

      expect(m.title).to eq data.title
    end
  end

  context "delete" do
    it "success" do
      expect(Misa.count).to eq 1

      visit misa_path(misa)
      click_link t("edit")
      click_link t("delete")

      expect(page).to have_title t("misa.misas")
      expect(Misa.count).to eq 0
    end
  end
end
