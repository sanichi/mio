require 'rails_helper'

describe Device do
  let(:data)    { build(:device) }
  let!(:device) { create(:device) }

  before(:each) do
    login
    click_link t(:device_devices)
  end

  context "create" do
    it "success" do
      click_link t(:device_new)
      fill_in t(:device_network__name), with: data.network_name
      fill_in t(:device_real__name), with: data.real_name
      fill_in t(:device_manufacturer), with: data.manufacturer
      fill_in t(:notes), with: data.notes
      click_button t(:save)

      expect(page).to have_title data.network_name

      expect(Device.count).to eq 2
      d = Device.last

      expect(d.network_name).to eq data.network_name
      expect(d.real_name).to eq data.real_name
      expect(d.manufacturer).to eq data.manufacturer
      expect(d.notes).to eq data.notes
    end

    it "failure" do
      click_link t(:device_new)
      fill_in t(:device_real__name), with: data.real_name
      fill_in t(:device_manufacturer), with: data.manufacturer
      fill_in t(:notes), with: data.notes
      click_button t(:save)

      expect(page).to have_title t(:device_new)
      expect(Device.count).to eq 1
      expect(page).to have_css(error, text: "blank")
    end
  end

  context "edit" do
    it "success" do
      click_link device.network_name
      click_link t(:edit)

      expect(page).to have_title t(:device_edit)
      fill_in t(:device_manufacturer), with: data.manufacturer
      click_button t(:save)

      expect(page).to have_title device.network_name

      expect(Device.count).to eq 1
      d = Device.last

      expect(d.manufacturer).to eq data.manufacturer
    end

    it "failure" do
      click_link device.network_name
      click_link t(:edit)

      fill_in t(:device_network__name), with: ""
      click_button t(:save)

      expect(page).to have_title t(:device_edit)
      expect(page).to have_css(error, text: "blank")
    end
  end

  context "delete" do
    it "success" do
      expect(Device.count).to eq 1

      click_link device.network_name
      click_link t(:edit)
      click_link t(:delete)

      expect(page).to have_title t(:device_devices)
      expect(Device.count).to eq 0
    end
  end
end
