require 'rails_helper'

describe Wk::Example, js: true do
  let(:data)     { build(:wk_example) }
  let!(:example) { create(:wk_example) }

  before(:each) do
    login
    click_link t("wk.japanese", locale: "jp")
    click_link t("wk.example.examples")
  end

  context "create" do
    it "success" do
      click_link t("wk.example.new")
      fill_in t("wk.example.japanese"), with: data.japanese
      fill_in t("wk.example.english"), with: data.english
      fill_in t("wk.example.day"), with: data.day
      click_button t("save")

      expect(page).to have_title t("wk.example.examples")

      expect(Wk::Example.count).to eq 2
      e = Wk::Example.last

      expect(e.japanese).to eq data.japanese
      expect(e.english).to eq data.english
      expect(e.day).to eq data.day
    end

    it "special" do
      click_link t("wk.example.new")
      fill_in t("wk.example.japanese"), with: " \s #{data.japanese}\t 　#{data.english}\t "
      fill_in t("wk.example.english"), with: ""
      click_button t("save")

      expect(page).to have_title t("wk.example.examples")

      expect(Wk::Example.count).to eq 2
      e = Wk::Example.last

      expect(e.japanese).to eq data.japanese
      expect(e.english).to eq data.english
      expect(e.day).to be_nil
    end

    it "failure" do
      click_link t("wk.example.new")
      fill_in t("wk.example.japanese"), with: data.japanese
      click_button t("save")

      expect(page).to have_title t("wk.example.new")
      expect(Wk::Example.count).to eq 1
      expect_error(page, "blank")
    end
  end

  context "edit" do
    it "success" do
      click_link t("edit")

      expect(page).to have_title t("wk.example.edit")
      fill_in t("wk.example.english"), with: data.english
      click_button t("save")

      expect(page).to have_title t("wk.example.examples")

      expect(Wk::Example.count).to eq 1
      e = Wk::Example.last

      expect(e.english).to eq data.english
    end
  end

  context "delete" do
    it "success" do
      expect(Wk::Example.count).to eq 1

      click_link t("edit")
      accept_confirm do
        click_link t("delete")
      end

      expect(page).to have_title t("wk.example.examples")
      expect(Wk::Example.count).to eq 0
    end
  end
end
