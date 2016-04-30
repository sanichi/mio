require 'rails_helper'

describe Opening do
  let(:data)     { build(:opening) }
  let!(:opening) { create(:opening) }

  before(:each) do
    login
    click_link t(:opening_openings)
  end

  context "create" do
    it "success" do
      click_link t(:opening_new)
      fill_in t(:opening_code), with: data.code
      fill_in t(:description), with: data.description
      click_button t(:save)

      expect(page).to have_title data.code

      expect(Opening.count).to eq 2
      o = Opening.last

      expect(o.code).to eq data.code
      expect(o.description).to eq data.description
    end

    it "failure" do
      click_link t(:opening_new)
      fill_in t(:description), with: data.description
      click_button t(:save)

      expect(page).to have_title t(:opening_new)
      expect(page).to have_css(error, text: "invalid")
      expect(Opening.count).to eq 1
    end
  end

  context "edit" do
    it "success" do
      click_link opening.code
      click_link t(:edit)

      expect(page).to have_title t(:opening_edit)
      fill_in t(:opening_code), with: data.code
      click_button t(:save)

      expect(page).to have_title data.code

      expect(Opening.count).to eq 1
      o = Opening.last

      expect(o.code).to eq data.code
    end

    it "failure" do
      click_link opening.code
      click_link t(:edit)

      fill_in t(:description), with: ""
      click_button t(:save)

      expect(page).to have_title t(:opening_edit)
      expect(page).to have_css(error, text: "blank")
    end
  end

  context "delete" do
    it "success" do
      expect(Opening.count).to eq 1

      click_link opening.code
      click_link t(:edit)
      click_link t(:delete)

      expect(page).to have_title t(:opening_openings)
      expect(Opening.count).to eq 0
    end
  end
end
