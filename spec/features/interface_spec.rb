require 'rails_helper'

describe Interface do
  let(:data)       { build(:interface, device_id: device.id) }
  let!(:interface) { create(:interface) }
  let!(:device)    { create(:device) }

  before(:each) do
    login
    click_link t(:interface_interfaces)
  end

  context "create" do
    it "success" do
      click_link t(:interface_new)
      fill_in t(:interface_name), with: data.name
      fill_in t(:interface_address), with: data.address
      select device.network_name, from: t(:device_device)
      click_button t(:save)

      expect(page).to have_title(data.name)

      expect(Interface.count).to eq 2
      i = Interface.last

      expect(i.name).to eq data.name
      expect(i.address).to eq data.address
      expect(i.device_id).to eq data.device_id
    end

    it "failure" do
      click_link t(:interface_new)
      fill_in t(:interface_name), with: data.name
      fill_in t(:interface_address), with: data.address
      click_button t(:save)

      expect(page).to have_title t(:interface_new)
      expect(Interface.count).to eq 1
      expect(page).to have_css(error, text: "not a number")
    end
  end

  context "edit" do
    it "success" do
      click_link interface.name
      click_link t(:edit)

      expect(page).to have_title t(:interface_edit)
      fill_in t(:interface_address), with: data.address
      click_button t(:save)

      expect(page).to have_title interface.name

      expect(Interface.count).to eq 1
      i = Interface.last

      expect(i.address).to eq data.address
    end

    it "failure" do
      click_link interface.name
      click_link t(:edit)

      fill_in t(:interface_name), with: ""
      click_button t(:save)

      expect(page).to have_title t(:interface_edit)
      expect(page).to have_css(error, text: "blank")
    end
  end

  context "delete" do
    it "success" do
      expect(Interface.count).to eq 1

      click_link interface.name
      click_link t(:edit)
      click_link t(:delete)

      expect(page).to have_title t(:interface_interfaces)
      expect(Interface.count).to eq 0
    end
  end
end
