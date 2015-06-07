require 'rails_helper'

describe Person do
  include_context "test_data"

  let(:atrs) { attributes_for(:person) }
  let(:data) { build(:person) }

  let(:error) { "div.help-block" }

  before(:each) do
    login
    click_link people
  end

  context "create" do
    it "success" do
      click_link new_person
      fill_in person_born, with: data.born
      fill_in person_died, with: data.died
      fill_in person_first_names, with: data.first_names
      fill_in person_last_name, with: data.last_name
      fill_in person_notes, with: data.notes
      check person_male if data.gender
      click_button save

      expect(page).to have_title data.name

      expect(Person.count).to eq 1
      p = Person.last

      expect(p.born).to eq data.born
      expect(p.died).to eq data.died
      expect(p.first_names).to eq data.first_names
      expect(p.last_name).to eq data.last_name
      expect(p.notes).to eq data.notes
    end
  end
  
  context "failure" do
    it "no last name" do
      click_link new_person
      fill_in person_born, with: data.born
      fill_in person_died, with: data.died
      fill_in person_first_names, with: data.first_names
      fill_in person_notes, with: data.notes
      check person_male if data.gender
      click_button save

      expect(page).to have_title new_person
      expect(Person.count).to eq 0
      expect(page).to have_css(error, text: "blank")
    end

    it "no birth year" do
      click_link new_person
      fill_in person_died, with: data.died
      fill_in person_first_names, with: data.first_names
      fill_in person_last_name, with: data.last_name
      fill_in person_notes, with: data.notes
      check person_male if data.gender
      click_button save

      expect(page).to have_title new_person
      expect(Person.count).to eq 0
      expect(page).to have_css(error, text: /not a number/)
    end

    it "died before born" do
      click_link new_person
      fill_in person_born, with: 1990
      fill_in person_died, with: 1920
      fill_in person_first_names, with: data.first_names
      fill_in person_last_name, with: data.last_name
      fill_in person_notes, with: data.notes
      check person_male if data.gender
      click_button save

      expect(page).to have_title new_person
      expect(Person.count).to eq 0
      expect(page).to have_css(error, text: /died.*before.*born/i)
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

      expect(page).to have_title person.name

      expect(Person.count).to eq 1
      p = Person.last

      expect(p.died).to eq year
    end
  end
  
  context "delete" do
    let!(:person) { create(:person) }

    it "success" do
      visit person_path(person)
      click_link edit
      click_link delete

      expect(page).to have_title people
      expect(Person.count).to eq 0
    end
  end
end
