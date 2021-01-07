require 'rails_helper'

describe Picture do
  let(:data)     { build(:picture) }
  let!(:person1) { create(:person, realm: data.realm) }
  let!(:person2) { create(:person, realm: data.realm) }
  let!(:person3) { create(:person, realm: data.realm) }

  before(:each) do
    login
    click_link t("person.people")
    select t("person.realms")[data.realm], from: t("person.realm")
    click_button t("search")
    within("#buttons") do
      click_link t("picture.pictures")
    end
  end

  context "create", type: :active_storage do

    context "success" do
      it "with people" do
        click_link t("picture.new")
        fill_in t("description"), with: data.description
        check t("picture.portrait") if data.portrait
        select person1.name(reversed: true, with_years: true), from: t("picture.person", number: 1)
        select person2.name(reversed: true, with_years: true), from: t("picture.person", number: 2)
        select t("person.realms")[data.realm], from: t("person.realm")
        click_button t("save")

        expect(PersonPicture.count).to eq 2
        expect(Picture.count).to eq 1
        p = Picture.last

        title = [person1, person2].sort{ |a, b| a.known_as <=> b.known_as }.map{ |p| p.name(full: false) }.join(", ")
        expect(page).to have_title title

        expect(p.description).to eq data.description
        expect(p.portrait).to eq data.portrait
        expect(p.people.size).to eq 2
        expect(p.people).to be_include(person1)
        expect(p.people).to be_include(person2)
        expect(p.title).to eq title
      end

      it "without people" do
        click_link t("picture.new")
        fill_in t("description"), with: data.description
        check t("picture.portrait") if data.portrait
        select t("person.realms")[data.realm], from: t("person.realm")
        click_button t("save")

        expect(PersonPicture.count).to eq 0
        expect(Picture.count).to eq 1
        p = Picture.last

        title = t("picture.picture")
        expect(page).to have_title title

        expect(p.description).to eq data.description
        expect(p.portrait).to eq data.portrait
        expect(p.people.size).to eq 0
        expect(p.title).to eq title
      end
    end
  end

  context "edit" do
    let!(:picture) do
      p = Picture.new(people: [person1, person2], description: data.description, realm: data.realm)
      p.save
      p
    end

    before(:each) do
      visit picture_path(picture)
      click_link t("edit")
      expect(page).to have_title t("picture.edit")
      expect(Picture.count).to eq 1
      expect(PersonPicture.count).to eq 2
    end

    it "people" do
      select person3.name(reversed: true, with_years: true), from: t("picture.person", number: 1)
      select t("select"), from: t("picture.person", number: 2)
      click_button t("save")

      title = person3.name(full: false)
      expect(page).to have_title title
      expect(Picture.count).to eq 1
      expect(PersonPicture.count).to eq 1

      picture.reload
      expect(picture.title).to eq title
      expect(picture.people.size).to eq 1
      expect(picture.people.first).to eq person3
    end

    it "description" do
      expect(picture.description).to be_present

      expect(page).to have_title t("picture.edit")
      fill_in t("description"), with: ""
      click_button t("save")

      expect(page).to_not have_title t("picture.edit")
      expect(Picture.count).to eq 1
      expect(PersonPicture.count).to eq 2

      picture.reload
      expect(picture.description).to be_nil
    end
  end

  context "delete" do
    let!(:picture) do
      p = Picture.new(people: [person1, person2, person3], description: data.description, realm: data.realm)
      p.save
      p
    end

    it "success" do
      expect(Picture.count).to eq 1
      expect(PersonPicture.count).to eq 3

      visit picture_path(picture)
      click_link t("edit")
      click_link t("delete")

      expect(page).to have_title t("picture.pictures")
      expect(Picture.count).to eq 0
      expect(PersonPicture.count).to eq 0
    end
  end
end
