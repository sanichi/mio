require 'rails_helper'

describe Partnership, js: true do
  let(:data)     { build(:partnership) }
  let!(:husband) { create(:person, male: true, born: data.wedding - 30, realm: data.realm) }
  let!(:wife)    { create(:person, male: false, born: data.wedding - 25, realm: data.realm) }

  before(:each) do
    login
    visit partnerships_path(realm: data.realm)
  end

  context "create" do
    it "success" do
      click_link t("partnership.new")
      select husband.name(reversed: true, with_years: true), from: t("partnership.husband")
      select wife.name(reversed: true, with_years: true), from: t("partnership.wife")
      fill_in t("partnership.wedding"), with: data.wedding
      check t("partnership.wedding_guess") if data.wedding_guess
      fill_in t("partnership.divorce"), with: data.divorce if data.divorce
      check t("partnership.divorce_guess") if data.divorce_guess
      uncheck t("partnership.marriage") unless data.marriage
      select t("person.realms")[data.realm], from: t("person.realm")
      click_button t("save")

      expect(page).to have_title t("partnership.partnership")

      expect(Partnership.count).to eq 1
      p = Partnership.last

      expect(p.husband_id).to eq husband.id
      expect(p.wife.id).to eq wife.id
      expect(p.wedding).to eq data.wedding
      expect(p.wedding_guess).to eq data.wedding_guess
      expect(p.divorce).to be_nil
      expect(p.divorce_guess).to eq data.divorce_guess
      expect(p.marriage).to be data.marriage
      expect(p.realm).to be data.realm
    end
  end

  context "failure" do
    it "no wife" do
      click_link t("partnership.new")
      select husband.name(reversed: true, with_years: true), from: t("partnership.husband")
      fill_in t("partnership.wedding"), with: data.wedding
      select t("person.realms")[data.realm], from: t("person.realm")
      click_button t("save")

      expect(page).to have_title t("partnership.new")
      expect(Partnership.count).to eq 0
      expect_error(page, "blank")
    end

    it "no wedding" do
      click_link t("partnership.new")
      select husband.name(reversed: true, with_years: true), from: t("partnership.husband")
      select wife.name(reversed: true, with_years: true), from: t("partnership.wife")
      select t("person.realms")[data.realm], from: t("person.realm")
      click_button t("save")

      expect(page).to have_title t("partnership.new")
      expect(Partnership.count).to eq 0
      expect_error(page, "blank")
    end

    it "wedding before born" do
      click_link t("partnership.new")
      select husband.name(reversed: true, with_years: true), from: t("partnership.husband")
      select wife.name(reversed: true, with_years: true), from: t("partnership.wife")
      fill_in t("partnership.wedding"), with: [husband.born, wife.born].min - 1
      select t("person.realms")[data.realm], from: t("person.realm")
      click_button t("save")

      expect(page).to have_title t("partnership.new")
      expect(Partnership.count).to eq 0
      expect_error(page, "before")
    end

    it "duplicate" do
      Partnership.create!(husband_id: husband.id, wife_id: wife.id, wedding: data.wedding, marriage: data.marriage, realm: data.realm)
      expect(Partnership.count).to eq 1

      click_link t("partnership.new")
      select husband.name(reversed: true, with_years: true), from: t("partnership.husband")
      select wife.name(reversed: true, with_years: true), from: t("partnership.wife")
      fill_in t("partnership.wedding"), with: data.wedding
      uncheck t("partnership.marriage") unless data.marriage
      select t("person.realms")[data.realm], from: t("person.realm")
      click_button t("save")

      expect(page).to have_title t("partnership.new")
      expect(Partnership.count).to eq 1
      expect_error(page, "already")
    end
  end

  context "edit" do
    let!(:partnership) { create(:partnership, realm: data.realm, husband: husband, wife: wife, marriage: data.marriage) }

    it "divorce" do
      expect(partnership.divorce).to be_nil
      year = Date.today.year

      visit partnership_path(partnership)
      click_link t("edit")
      expect(page).to have_title t("partnership.edit")
      fill_in t("partnership.divorce"), with: year
      check t("partnership.divorce_guess")
      click_button t("save")

      expect(page).to have_title t("partnership.partnership")

      expect(Partnership.count).to eq 1
      p = Partnership.last

      expect(p.divorce).to eq year
      expect(p.divorce_guess).to eq true
    end
  end

  context "delete" do
    let!(:partnership) { create(:partnership, realm: data.realm, husband: husband, wife: wife, marriage: data.marriage) }

    it "success" do
      expect(Partnership.count).to eq 1

      visit partnership_path(partnership)
      click_link t("edit")
      accept_confirm do
        click_link t("delete")
      end

      expect(page).to have_title t("partnership.partnerships")
      expect(Partnership.count).to eq 0
    end
  end
end
