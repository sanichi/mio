require 'rails_helper'

describe Resident do
  let(:data)      { build(:resident) }
  let!(:resident) { create(:resident) }

  before(:each) do
    login
    click_link t("resident.residents")
  end

  context "create" do
    it "success" do
      click_link t("resident.new")
      fill_in t("person.first_names"), with: data.first_names
      fill_in t("person.last_name"), with: data.last_name
      fill_in t("email"), with: data.email
      fill_in t("resident.address"), with: data.address
      fill_in t("resident.agent"), with: data.agent
      click_button t("save")

      expect(page).to have_title t("resident.resident")

      expect(Resident.count).to eq 2
      r = Resident.last

      expect(r.first_names).to eq data.first_names
      expect(r.last_name).to eq data.last_name
      expect(r.email).to eq data.email
      expect(r.address).to eq data.address
      expect(r.agent).to eq data.agent
    end

    it "failure" do
      click_link t("resident.new")
      fill_in t("person.last_name"), with: data.last_name
      fill_in t("email"), with: data.email
      click_button t("save")

      expect(page).to have_title t("resident.new")
      expect(Resident.count).to eq 1
      expect(page).to have_css(error, text: "blank")
    end
  end

  context "edit" do
    it "success" do
      click_link resident.name
      click_link t("edit")

      expect(page).to have_title t("resident.edit")
      fill_in t("person.first_names"), with: data.first_names
      click_button t("save")

      expect(page).to have_title t("resident.resident")

      expect(Resident.count).to eq 1
      r = Resident.last

      expect(r.first_names).to eq data.first_names
    end

    it "failure" do
      click_link resident.name
      click_link t("edit")

      fill_in t("person.last_name"), with: ""
      click_button t("save")

      expect(page).to have_title t("resident.edit")
      expect(page).to have_css(error, text: "blank")
    end
  end

  context "delete" do
    it "success" do
      expect(Resident.count).to eq 1

      click_link resident.name
      click_link t("edit")
      click_link t("delete")

      expect(page).to have_title t("resident.residents")
      expect(Resident.count).to eq 0
    end
  end
end
