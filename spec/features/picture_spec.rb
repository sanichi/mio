require 'rails_helper'

describe Picture do
  let(:data)     { build(:picture) }
  let!(:person1) { create(:person) }
  let!(:person2) { create(:person) }
  let!(:person3) { create(:person) }

  let(:image_dir) { Rails.root + "spec/files/" }

  before(:each) do
    login
    click_link t(:picture_pictures)
  end

  context "create" do
    let(:file) { "malcolm.jpg" }

    context "success" do
      it "with people" do
        click_link t(:picture_new)
        fill_in t(:description), with: data.description
        check t(:picture_portrait) if data.portrait
        attach_file t(:picture_file), image_dir + file
        select person1.name(reversed: true, with_years: true), from: t(:picture_person, number: 1)
        select person2.name(reversed: true, with_years: true), from: t(:picture_person, number: 2)
        click_button t(:save)

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
        expect(p.image_file_name).to eq file
        expect(p.image_content_type).to eq "image/jpeg"
        expect(p.image_file_size).to eq 13738
      end

      it "without people" do
        click_link t(:picture_new)
        fill_in t(:description), with: data.description
        check t(:picture_portrait) if data.portrait
        attach_file t(:picture_file), image_dir + file
        click_button t(:save)

        expect(PersonPicture.count).to eq 0
        expect(Picture.count).to eq 1
        p = Picture.last

        title = t(:picture_picture)
        expect(page).to have_title title

        expect(p.description).to eq data.description
        expect(p.portrait).to eq data.portrait
        expect(p.people.size).to eq 0
        expect(p.title).to eq title
        expect(p.image_file_name).to eq file
        expect(p.image_content_type).to eq "image/jpeg"
        expect(p.image_file_size).to eq 13738
      end
    end

    context "failure" do
      let(:file_bad_name) { "malcolm.txt" }
      let(:file_bad_type) { "malcolm.gif" }

      it "bad name" do
        click_link t(:picture_new)
        fill_in t(:description), with: data.description
        check t(:picture_portrait) if data.portrait
        attach_file t(:picture_file), image_dir + file_bad_name
        select person1.name(reversed: true, with_years: true), from: t(:picture_person, number: 1)
        click_button t(:save)

        expect(page).to have_title t(:picture_new)
        expect(Picture.count).to eq 0
        expect(PersonPicture.count).to eq 0
        expect(page).to have_css(error, text: "contents")
      end

      it "bad type" do
        click_link t(:picture_new)
        fill_in t(:description), with: data.description
        check t(:picture_portrait) if data.portrait
        attach_file t(:picture_file), image_dir + file_bad_type
        select person1.name(reversed: true, with_years: true), from: t(:picture_person, number: 1)
        click_button t(:save)

        expect(page).to have_title t(:picture_new)
        expect(Picture.count).to eq 0
        expect(PersonPicture.count).to eq 0
        expect(page).to have_css(error, text: "Paperclip::Errors::NotIdentifiedByImageMagickError") # should really be proper English message, probably PaperClip problem
      end
    end
  end

  context "edit" do
    let!(:picture) { create(:picture, people: [person1, person2]) }

    before(:each) do
      visit picture_path(picture)
      click_link t(:edit)
      expect(page).to have_title t(:picture_edit)
      expect(Picture.count).to eq 1
      expect(PersonPicture.count).to eq 2
    end

    it "people" do
      select person3.name(reversed: true, with_years: true), from: t(:picture_person, number: 1)
      select t(:select), from: t(:picture_person, number: 2)
      click_button t(:save)

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

      expect(page).to have_title t(:picture_edit)
      fill_in t(:description), with: ""
      click_button t(:save)

      expect(page).to_not have_title t(:picture_edit)
      expect(Picture.count).to eq 1
      expect(PersonPicture.count).to eq 2

      picture.reload
      expect(picture.description).to be_nil
    end
  end

  context "delete" do
    let!(:picture) { create(:picture, people: [person1, person2, person3]) }

    it "success" do
      expect(Picture.count).to eq 1
      expect(PersonPicture.count).to eq 3

      visit picture_path(picture)
      click_link t(:edit)
      click_link t(:delete)

      expect(page).to have_title t(:picture_pictures)
      expect(Picture.count).to eq 0
      expect(PersonPicture.count).to eq 0
    end
  end
end
