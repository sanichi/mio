require 'rails_helper'

describe Interface do
  let(:data)       { build(:interface, device_id: device.id) }
  let!(:interface) { create(:interface) }
  let!(:device)    { create(:device) }

  before(:each) do
    login
    click_link t("interface.interfaces")
  end

  context "create" do
    it "success" do
      click_link t("interface.new")
      fill_in t("interface.name"), with: data.name
      fill_in t("interface.mac_address"), with: data.mac_address
      fill_in t("interface.manufacturer"), with: data.manufacturer
      fill_in t("interface.ip_address"), with: data.ip_address
      select device.name, from: t("device.device")
      click_button t("save")

      expect(page).to have_title(data.name)

      expect(Interface.count).to eq 2
      i = Interface.last

      expect(i.name).to eq data.name
      expect(i.mac_address).to eq data.mac_address
      expect(i.ip_address).to eq data.ip_address
      expect(i.manufacturer).to eq data.manufacturer
      expect(i.device_id).to eq data.device_id
    end

    it "failure" do
      click_link t("interface.new")
      fill_in t("interface.name"), with: data.name
      fill_in t("interface.mac_address"), with: data.mac_address
      fill_in t("interface.manufacturer"), with: data.manufacturer
      fill_in t("interface.ip_address"), with: data.ip_address
      click_button t("save")

      expect(page).to have_title t("interface.new")
      expect(Interface.count).to eq 1
      expect(page).to have_css(error, text: "not a number")
    end
  end

  context "edit" do
    it "success" do
      click_link interface.name
      click_link t("edit")

      expect(page).to have_title t("interface.edit")
      fill_in t("interface.mac_address"), with: data.mac_address
      click_button t("save")

      expect(page).to have_title interface.name

      expect(Interface.count).to eq 1
      i = Interface.last

      expect(i.mac_address).to eq data.mac_address
    end

    it "failure" do
      click_link interface.name
      click_link t("edit")

      fill_in t("interface.name"), with: ""
      click_button t("save")

      expect(page).to have_title t("interface.edit")
      expect(page).to have_css(error, text: "blank")
    end
  end

  context "delete" do
    it "success" do
      expect(Interface.count).to eq 1

      click_link interface.name
      click_link t("edit")
      click_link t("delete")

      expect(page).to have_title t("interface.interfaces")
      expect(Interface.count).to eq 0
    end
  end
end
