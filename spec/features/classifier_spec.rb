require 'rails_helper'

describe Classifier, js: true do
  let(:data)        { build(:classifier) }
  let!(:classifier) { create(:classifier) }

  before(:each) do
    login
    click_link t("other")
    click_link t("classifier.classifiers")
  end

  context "create" do
    it "success" do
      click_link t("classifier.new")
      fill_in t("classifier.name"), with: data.name
      fill_in t("classifier.category"), with: data.category
      fill_in t("classifier.max_amount"), with: data.max_amount
      fill_in t("classifier.min_amount"), with: data.min_amount
      fill_in t("classifier.color"), with: data.color
      fill_in t("classifier.description"), with: data.description
      click_button t("save")

      expect(page).to have_title data.name

      expect(Classifier.count).to eq 2
      c = Classifier.find(Classifier.maximum(:id))

      expect(c.name).to eq data.name
      expect(c.category).to eq data.category
      expect(c.max_amount).to eq data.max_amount
      expect(c.min_amount).to eq data.min_amount
      expect(c.color).to eq data.color
      expect(c.description).to eq data.description
    end

    it "failure" do
      click_link t("classifier.new")
      fill_in t("classifier.name"), with: data.name
      fill_in t("classifier.category"), with: data.category
      fill_in t("classifier.max_amount"), with: data.max_amount
      fill_in t("classifier.min_amount"), with: data.min_amount
      fill_in t("classifier.color"), with: data.color
      # fill_in t("classifier.description"), with: data.description
      click_button t("save")

      expect(page).to have_title t("classifier.new")
      expect(Classifier.count).to eq 1
      expect_error(page, "blank")
    end
  end

  context "edit" do
    it "success" do
      click_link classifier.name
      click_link t("edit")

      expect(page).to have_title t("classifier.edit")
      fill_in t("classifier.name"), with: data.name
      click_button t("save")

      expect(page).to have_title data.name

      expect(Classifier.count).to eq 1
      c = Classifier.last

      expect(c.name).to eq data.name
    end
  end

  context "delete" do
    it "success" do
      expect(Classifier.count).to eq 1

      click_link classifier.name
      click_link t("edit")
      accept_confirm do
        click_link t("delete")
      end

      expect(page).to have_title t("classifier.classifiers")
      expect(Classifier.count).to eq 0
    end
  end
end
