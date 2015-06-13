require 'rails_helper'

describe Marriage do
  include_context "test_data"

  let(:atrs) { attributes_for(:marriage) }
  let(:data) { build(:marriage) }
  
  let!(:husband) { create(:person, gender: true, born: data.wedding - 30) }
  let!(:wife)    { create(:person, gender: false, born: data.wedding - 25) }

  before(:each) do
    login
    click_link marriages
  end

  context "create" do
    it "success" do
      click_link new_marriage
      select husband.name(reversed: true), from: marriage_husband
      select wife.name(reversed: true), from: marriage_wife
      fill_in marriage_wedding, with: data.wedding
      click_button save

      expect(page).to have_title marriage_singular

      expect(Marriage.count).to eq 1
      m = Marriage.last

      expect(m.husband_id).to eq husband.id
      expect(m.wife.id).to eq wife.id
      expect(m.wedding).to eq data.wedding
      expect(m.divorce).to be_nil
    end
  end

  context "failure" do
    it "no wife" do
      click_link new_marriage
      select husband.name(reversed: true), from: marriage_husband
      fill_in marriage_wedding, with: data.wedding
      click_button save

      expect(page).to have_title new_marriage
      expect(Marriage.count).to eq 0
      expect(page).to have_css(error, text: "blank")
    end

    it "no wedding" do
      click_link new_marriage
      select husband.name(reversed: true), from: marriage_husband
      select wife.name(reversed: true), from: marriage_wife
      click_button save

      expect(page).to have_title new_marriage
      expect(Marriage.count).to eq 0
      expect(page).to have_css(error, text: "blank")
    end

    it "wedding before born" do
      click_link new_marriage
      select husband.name(reversed: true), from: marriage_husband
      select wife.name(reversed: true), from: marriage_wife
      fill_in marriage_wedding, with: [data.husband.born, data.wife.born].min - 1
      click_button save

      expect(page).to have_title new_marriage
      expect(Marriage.count).to eq 0
      expect(page).to have_css(error, text: /before.*born/i)
    end
  end

  context "edit" do
    let(:marriage) { create(:marriage) }

    it "divorce" do
      expect(marriage.divorce).to be_nil
      year = Date.today.year

      visit marriage_path(marriage)
      click_link edit
      expect(page).to have_title edit_marriage
      fill_in marriage_wedding, with: year
      click_button save

      expect(page).to have_title marriage_singular

      expect(Marriage.count).to eq 1
      m = Marriage.last

      expect(m.wedding).to eq year
    end
  end

  context "delete" do
    let!(:marriage) { create(:marriage) }

    it "success" do
      expect(Marriage.count).to eq 1

      visit marriage_path(marriage)
      click_link edit
      click_link delete

      expect(page).to have_title marriages
      expect(Marriage.count).to eq 0
    end
  end
end
