require 'rails_helper'

describe Person do
  let(:data)    { build(:person) }
  let!(:father) { create(:person, male: true, born: data.born - 26, realm: data.realm) }
  let!(:mother) { create(:person, male: false, born: data.born - 24, realm: data.realm) }

  let(:count)   { 2 }

  before(:each) do
    login
    click_link t(:person_people)
  end

  context "create" do
    it "success" do
      click_link t(:person_new)
      fill_in t(:person_last__name), with: data.last_name
      fill_in t(:person_first__names), with: data.first_names
      fill_in t(:person_known__as), with: data.known_as
      fill_in t(:person_born), with: data.born
      check t(:person_born__guess) if data.born_guess
      fill_in t(:person_died), with: data.died
      check t(:person_died__guess) if data.died_guess
      select father.name(reversed: true, with_years: true, with_married_name: true), from: t(:person_father)
      select t(:person_realms)[data.realm], from: t(:person_realm)
      select mother.name(reversed: true, with_years: true, with_married_name: true), from: t(:person_mother)
      fill_in t(:person_notes), with: data.notes
      check t(:person_male) if data.male
      fill_in t(:person_married__name), with: data.married_name
      click_button t(:save)

      # expect(page).to have_title data.name(full: false)

      expect(Person.count).to eq count + 1
      p = Person.last

      expect(p.last_name).to eq data.last_name
      expect(p.first_names).to eq data.first_names
      expect(p.known_as).to eq data.known_as
      expect(p.born).to eq data.born
      expect(p.born_guess).to eq data.born_guess
      expect(p.died).to eq data.died
      expect(p.died_guess).to eq data.died_guess
      expect(p.realm).to eq data.realm
      expect(p.male).to eq data.male
      expect(p.married_name).to eq data.married_name
      expect(p.father_id).to eq father.id
      expect(p.mother_id).to eq mother.id
      expect(p.notes).to eq data.notes
    end

    it "minimum data" do
      click_link t(:person_new)
      fill_in t(:person_last__name), with: data.last_name
      fill_in t(:person_first__names), with: data.first_names
      fill_in t(:person_born), with: data.born
      click_button t(:save)

      expect(page).to have_title data.last_name

      expect(Person.count).to eq count + 1
      p = Person.last

      expect(p.last_name).to eq data.last_name
      expect(p.first_names).to eq data.first_names
      expect(p.known_as).to eq p.first_names.split(" ").first
      expect(p.born).to eq data.born
      expect(p.born_guess).to eq false
      expect(p.died).to be_nil
      expect(p.died_guess).to eq false
      expect(p.male).to eq false
      expect(p.married_name).to be_nil
      expect(p.father_id).to be_nil
      expect(p.mother_id).to be_nil
      expect(p.notes).to be_nil
    end
  end

  context "failure" do
    it "no last name" do
      click_link t(:person_new)
      fill_in t(:person_first__names), with: data.first_names
      fill_in t(:person_born), with: data.born
      click_button t(:save)

      expect(page).to have_title t(:person_new)
      expect(Person.count).to eq count
      expect(page).to have_css(error, text: "blank")
    end

    it "no birth year" do
      click_link t(:person_new)
      fill_in t(:person_last__name), with: data.last_name
      fill_in t(:person_first__names), with: data.first_names
      click_button t(:save)

      expect(page).to have_title t(:person_new)
      expect(Person.count).to eq count
      expect(page).to have_css(error, text: /not a number/)
    end

    it "died before born" do
      click_link t(:person_new)
      fill_in t(:person_last__name), with: data.last_name
      fill_in t(:person_first__names), with: data.first_names
      fill_in t(:person_born), with: 1990
      fill_in t(:person_died), with: 1920
      click_button t(:save)

      expect(page).to have_title t(:person_new)
      expect(Person.count).to eq count
      expect(page).to have_css(error, text: /died.*born/i)
    end

    it "born before father" do
      click_link t(:person_new)
      fill_in t(:person_last__name), with: data.last_name
      fill_in t(:person_first__names), with: data.first_names
      fill_in t(:person_born), with: father.born
      select father.name(reversed: true, with_years: true), from: t(:person_father)
      click_button t(:save)

      expect(page).to have_title t(:person_new)
      expect(Person.count).to eq count
      expect(page).to have_css(error, text: /born.*father/i)
    end
  end

  context "edit" do
    let(:person) { create(:person) }

    it "died" do
      visit person_path(person)
      click_link t(:edit)
      year = Date.today.year

      expect(page).to have_title t(:person_edit)
      fill_in t(:person_died), with: year
      check t(:person_died__guess)
      click_button t(:save)

      expect(page).to have_title person.name(full: false)

      expect(Person.count).to eq count + 1
      p = Person.last

      expect(p.died).to eq year
      expect(p.died_guess).to eq true
    end
  end

  context "delete" do
    let!(:person) { create(:person) }

    it "success" do
      expect(Person.count).to eq count + 1

      visit person_path(person)
      click_link t(:edit)
      click_link t(:delete)

      expect(page).to have_title t(:person_people)
      expect(Person.count).to eq count
    end
  end
end
