require 'rails_helper'

describe Partnership do
  include_context "test_data"

  let(:atrs) { attributes_for(:partnership) }
  let(:data) { build(:partnership) }

  let!(:husband) { create(:person, male: true, born: data.wedding - 30) }
  let!(:wife)    { create(:person, male: false, born: data.wedding - 25) }

  before(:each) do
    login
    click_link partnerships
  end

  context "create" do
    it "success" do
      click_link new_partnership
      select husband.name(reversed: true, with_years: true), from: partnership_husband
      select wife.name(reversed: true, with_years: true), from: partnership_wife
      fill_in partnership_wedding, with: data.wedding
      check partnership_wedding_guess if data.wedding_guess
      fill_in partnership_divorce, with: data.divorce if data.divorce
      check partnership_divorce_guess if data.divorce_guess
      uncheck partnership_marriage unless data.marriage
      click_button save

      expect(page).to have_title partnership_singular

      expect(Partnership.count).to eq 1
      p = Partnership.last

      expect(p.husband_id).to eq husband.id
      expect(p.wife.id).to eq wife.id
      expect(p.wedding).to eq data.wedding
      expect(p.wedding_guess).to eq data.wedding_guess
      expect(p.divorce).to be_nil
      expect(p.divorce_guess).to eq data.divorce_guess
      expect(p.marriage).to be data.marriage
    end
  end

  context "failure" do
    it "no wife" do
      click_link new_partnership
      select husband.name(reversed: true, with_years: true), from: partnership_husband
      fill_in partnership_wedding, with: data.wedding
      click_button save

      expect(page).to have_title new_partnership
      expect(Partnership.count).to eq 0
      expect(page).to have_css(error, text: "blank")
    end

    it "no wedding" do
      click_link new_partnership
      select husband.name(reversed: true, with_years: true), from: partnership_husband
      select wife.name(reversed: true, with_years: true), from: partnership_wife
      click_button save

      expect(page).to have_title new_partnership
      expect(Partnership.count).to eq 0
      expect(page).to have_css(error, text: "blank")
    end

    it "wedding before born" do
      click_link new_partnership
      select husband.name(reversed: true, with_years: true), from: partnership_husband
      select wife.name(reversed: true, with_years: true), from: partnership_wife
      fill_in partnership_wedding, with: [data.husband.born, data.wife.born].min - 1
      click_button save

      expect(page).to have_title new_partnership
      expect(Partnership.count).to eq 0
      expect(page).to have_css(error, text: /before.*born/i)
    end

    it "duplicate" do
      Partnership.create!(husband_id: husband.id, wife_id: wife.id, wedding: data.wedding, marriage: data.marriage)
      expect(Partnership.count).to eq 1

      click_link new_partnership
      select husband.name(reversed: true, with_years: true), from: partnership_husband
      select wife.name(reversed: true, with_years: true), from: partnership_wife
      fill_in partnership_wedding, with: data.wedding
      uncheck partnership_marriage unless data.marriage
      click_button save

      expect(page).to have_title new_partnership
      expect(Partnership.count).to eq 1
      expect(page).to have_css(error, text: /already.*taken/i)
    end
  end

  context "edit" do
    let(:partnership) { create(:partnership) }

    it "divorce" do
      expect(partnership.divorce).to be_nil
      year = Date.today.year

      visit partnership_path(partnership)
      click_link edit
      expect(page).to have_title edit_partnership
      fill_in partnership_divorce, with: year
      check partnership_divorce_guess
      click_button save

      expect(page).to have_title partnership_singular

      expect(Partnership.count).to eq 1
      p = Partnership.last

      expect(p.divorce).to eq year
      expect(p.divorce_guess).to eq true
    end
  end

  context "delete" do
    let!(:partnership) { create(:partnership) }

    it "success" do
      expect(Partnership.count).to eq 1

      visit partnership_path(partnership)
      click_link edit
      click_link delete

      expect(page).to have_title partnerships
      expect(Partnership.count).to eq 0
    end
  end
end
