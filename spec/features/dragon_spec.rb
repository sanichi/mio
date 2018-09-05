require 'rails_helper'

describe Dragon do
  let(:data)    { build(:dragon) }
  let!(:dragon) { create(:dragon) }

  let(:table) { "//table/tbody/tr[td[.='%s, %s']]" }

  before(:each) do
    login
    visit dragons_path
  end

  context "create" do
    it "success" do
      click_link t(:dragon_new)
      fill_in t(:person_first__name), with: data.first_name
      fill_in t(:person_last__name), with: data.last_name
      if data.male
        check t(:person_male)
      else
        uncheck t(:person_male)
      end
      click_button t(:save)

      expect(page).to have_title t(:dragon_dragons)
      expect(page).to have_xpath table % [data.last_name, data.first_name]

      expect(Dragon.count).to eq 2
      d = Dragon.last

      expect(d.first_name).to eq data.first_name
      expect(d.last_name).to eq data.last_name
      expect(d.male).to eq data.male
    end
  end

  context "failure" do
    it "no first name" do
      click_link t(:dragon_new)
      fill_in t(:person_last__name), with: data.last_name
      if data.male
        check t(:person_male)
      else
        uncheck t(:person_male)
      end
      click_button t(:save)

      expect(page).to have_title t(:dragon_new)
      expect(Dragon.count).to eq 1
      expect(page).to have_css(error, text: "blank")
    end
  end

  context "edit" do
    it "success" do
      visit dragons_path
      click_link dragon.name(true)

      expect(page).to have_title t(:dragon_edit)
      fill_in t(:person_last__name), with: data.last_name
      click_button t(:save)

      expect(page).to have_title t(:dragon_dragons)

      expect(Dragon.count).to eq 1
      d = Dragon.last

      expect(d.last_name).to eq data.last_name
    end
  end

  context "delete" do
    it "success" do
      visit dragons_path
      click_link dragon.name(true)
      click_link t(:delete)

      expect(page).to have_title t(:dragon_dragons)
      expect(Dragon.count).to eq 0
    end
  end
end
