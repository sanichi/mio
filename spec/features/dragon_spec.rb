require 'rails_helper'

describe Dragon do
  let(:data)    { build(:dragon) }
  let!(:dragon) { create(:dragon) }

  let(:table) { "//table/tbody/tr/td/a[.=\"%s,\u00a0%s\"]" }

  before(:each) do
    login
    visit dragons_path
  end

  context "create" do
    it "success" do
      click_link t("dragon.new")
      fill_in t("person.first_name"), with: data.first_name
      fill_in t("person.last_name"), with: data.last_name
      if data.male
        check t("person.male")
      else
        uncheck t("person.male")
      end
      click_button t("save")

      expect(page).to have_title t("dragon.dragons")
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
      click_link t("dragon.new")
      fill_in t("person.last_name"), with: data.last_name
      if data.male
        check t("person.male")
      else
        uncheck t("person.male")
      end
      click_button t("save")

      expect(page).to have_title t("dragon.new")
      expect(Dragon.count).to eq 1
      expect(page).to have_css(error, text: "blank")
    end

    it "duplicates" do
      click_link t("dragon.new")
      fill_in t("person.first_name"), with: dragon.first_name
      fill_in t("person.last_name"), with: dragon.last_name
      if dragon.male
        check t("person.male")
      else
        uncheck t("person.male")
      end
      click_button t("save")

      expect(page).to have_title t("dragon.new")
      expect(Dragon.count).to eq 1
      expect(page).to have_css(error, text: t("dragon.duplicate"))
    end
  end

  context "edit" do
    it "success" do
      visit dragons_path
      click_link dragon.name(true)

      expect(page).to have_title t("dragon.edit")
      fill_in t("person.last_name"), with: data.last_name
      click_button t("save")

      expect(page).to have_title t("dragon.dragons")

      expect(Dragon.count).to eq 1
      d = Dragon.last

      expect(d.last_name).to eq data.last_name
    end
  end

  context "delete" do
    it "success" do
      visit dragons_path
      click_link dragon.name(true)
      click_link t("delete")

      expect(page).to have_title t("dragon.dragons")
      expect(Dragon.count).to eq 0
    end
  end
end
