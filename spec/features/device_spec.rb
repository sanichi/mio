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
      fill_in t(:device_name), with: data.name
      fill_in t(:notes), with: data.notes
      click_button t(:save)

      expect(page).to have_title data.name

      expect(Device.count).to eq 2
      d = Device.last

      expect(d.name).to eq data.name
      expect(d.notes).to eq data.notes
    end

    it "failure" do
      click_link t(:device_new)
      fill_in t(:notes), with: data.notes
      click_button t(:save)

      expect(page).to have_title t(:device_new)
      expect(Device.count).to eq 1
      expect(page).to have_css(error, text: "blank")
    end
  end

  context "edit" do
    it "success" do
      click_link device.name
      click_link t(:edit)

      expect(page).to have_title t(:device_edit)
      fill_in t(:device_name), with: data.name
      click_button t(:save)

      expect(page).to have_title data.name

      expect(Device.count).to eq 1
      d = Device.last

      expect(d.name).to eq data.name
    end

    it "failure" do
      click_link device.name
      click_link t(:edit)

      fill_in t(:device_name), with: ""
      click_button t(:save)

      expect(page).to have_title t(:device_edit)
      expect(page).to have_css(error, text: "blank")
    end
  end

  context "delete" do
    it "success" do
      expect(Device.count).to eq 1

      click_link device.name
      click_link t(:edit)
      click_link t(:delete)

      expect(page).to have_title t(:device_devices)
      expect(Device.count).to eq 0
    end
  end
end
