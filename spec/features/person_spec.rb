require 'rails_helper'

describe Person do
  include_context "test_data"

  let(:data)    { build(:person) }
  let!(:father) { create(:person, male: true, born: data.born - 26) }
  let!(:mother) { create(:person, male: false, born: data.born - 24) }

  let(:count)   { 2 }

  before(:each) do
    login
    click_link people
  end

  context "create" do
    it "success" do
      click_link new_person
      fill_in person_last_name, with: data.last_name
      fill_in person_first_names, with: data.first_names
      fill_in person_known_as, with: data.known_as
      fill_in person_born, with: data.born
      fill_in person_died, with: data.died
      select father.name(reversed: true, with_years: true), from: person_father
      select mother.name(reversed: true, with_years: true), from: person_mother
      fill_in person_notes, with: data.notes
      check person_male if data.male
      click_button save

      expect(page).to have_title data.name(full: false)

      expect(Person.count).to eq count + 1
      p = Person.last

      expect(p.last_name).to eq data.last_name
      expect(p.first_names).to eq data.first_names
      expect(p.known_as).to eq data.known_as
      expect(p.born).to eq data.born
      expect(p.died).to eq data.died
      expect(p.male).to eq data.male
      expect(p.father_id).to eq father.id
      expect(p.mother_id).to eq mother.id
      expect(p.notes).to eq data.notes
    end

    it "minimum data" do
      click_link new_person
      fill_in person_last_name, with: data.last_name
      fill_in person_first_names, with: data.first_names
      fill_in person_born, with: data.born
      click_button save

      expect(page).to have_title data.last_name

      expect(Person.count).to eq count + 1
      p = Person.last

      expect(p.last_name).to eq data.last_name
      expect(p.first_names).to eq data.first_names
      expect(p.known_as).to eq p.first_names.split(" ").first
      expect(p.born).to eq data.born
      expect(p.died).to be_nil
      expect(p.male).to eq false
      expect(p.father_id).to be_nil
      expect(p.mother_id).to be_nil
      expect(p.notes).to be_nil
    end
  end

  context "failure" do
    it "no last name" do
      click_link new_person
      fill_in person_first_names, with: data.first_names
      fill_in person_born, with: data.born
      click_button save

      expect(page).to have_title new_person
      expect(Person.count).to eq count
      expect(page).to have_css(error, text: "blank")
    end

    it "no birth year" do
      click_link new_person
      fill_in person_last_name, with: data.last_name
      fill_in person_first_names, with: data.first_names
      click_button save

      expect(page).to have_title new_person
      expect(Person.count).to eq count
      expect(page).to have_css(error, text: /not a number/)
    end

    it "died before born" do
      click_link new_person
      fill_in person_last_name, with: data.last_name
      fill_in person_first_names, with: data.first_names
      fill_in person_born, with: 1990
      fill_in person_died, with: 1920
      click_button save

      expect(page).to have_title new_person
      expect(Person.count).to eq count
      expect(page).to have_css(error, text: /died.*born/i)
    end

    it "born before father" do
      click_link new_person
      fill_in person_last_name, with: data.last_name
      fill_in person_first_names, with: data.first_names
      fill_in person_born, with: father.born
      select father.name(reversed: true, with_years: true), from: person_father
      click_button save

      expect(page).to have_title new_person
      expect(Person.count).to eq count
      expect(page).to have_css(error, text: /born.*father/i)
    end
  end

  context "edit" do
    let(:person) { create(:person) }

    it "died" do
      visit person_path(person)
      click_link edit
      year = Date.today.year

      expect(page).to have_title edit_person
      fill_in person_died, with: year
      click_button save

      expect(page).to have_title person.name(full: false)

      expect(Person.count).to eq count + 1
      p = Person.last

      expect(p.died).to eq year
    end
  end

  context "delete" do
    let!(:person) { create(:person) }

    it "success" do
      expect(Person.count).to eq count + 1

      visit person_path(person)
      click_link edit
      click_link delete

      expect(page).to have_title people
      expect(Person.count).to eq count
    end
  end
end
