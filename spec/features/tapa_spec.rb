require 'rails_helper'

describe Tapa do
  let(:data)  { build(:tapa) }
  let!(:tapa) { create(:tapa) }

  before(:each) do
    login
    click_link t("tapa.tapas")
  end

  context "create" do
    it "success" do
      click_link t("tapa.new")
      fill_in t("tapa.number"), with: data.number
      fill_in t("tapa.title"), with: data.title
      fill_in t("tapa.keywords"), with: data.keywords
      fill_in t("tapa.post_id"), with: data.post_id
      check t("tapa.star") if data.star
      fill_in t("notes"), with: data.notes
      click_button t("save")

      expect(page).to have_title t("tapa.tapas")

      expect(Tapa.count).to eq 2
      t = Tapa.last

      expect(t.number).to eq data.number
      expect(t.title).to eq data.title
      expect(t.keywords).to eq data.keywords
      expect(t.post_id).to eq data.post_id
      expect(t.star).to eq data.star
      expect(t.notes).to eq data.notes
    end

    it "failure" do
      click_link t("tapa.new")
      fill_in t("tapa.number"), with: tapa.number
      fill_in t("tapa.title"), with: data.title
      fill_in t("tapa.keywords"), with: data.keywords
      fill_in t("tapa.post_id"), with: data.post_id
      check t("tapa.star") if data.star
      fill_in t("notes"), with: data.notes
      click_button t("save")

      expect(page).to have_title t("tapa.new")
      expect(Tapa.count).to eq 1
      expect(page).to have_css(error, text: "taken")
    end
  end

  context "edit" do
    it "success" do
      click_link t("edit")

      expect(page).to have_title t("tapa.edit")
      fill_in t("tapa.title"), with: data.title
      click_button t("save")

      expect(page).to have_title t("tapa.tapas")

      expect(Tapa.count).to eq 1
      t = Tapa.last

      expect(t.title).to eq data.title
    end

    it "failure" do
      click_link t("edit")

      fill_in t("tapa.title"), with: ""
      click_button t("save")

      expect(page).to have_title t("tapa.edit")
      expect(page).to have_css(error, text: "blank")
    end
  end

  context "delete" do
    it "success" do
      expect(Tapa.count).to eq 1

      click_link t("edit")
      click_link t("delete")

      expect(page).to have_title t("tapa.tapas")
      expect(Tapa.count).to eq 0
    end
  end
end
