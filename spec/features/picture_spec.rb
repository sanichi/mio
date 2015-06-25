require 'rails_helper'

describe Picture do
  include_context "test_data"

  let(:data)    { build(:picture) }
  let!(:person) { create(:person) }

  let(:image_dir) { Rails.root + "spec/files/" }

  before(:each) do
    login
    click_link pictures
  end

  context "create" do
    let(:file) { "malcolm.jpg" }

    it "success" do
      click_link new_picture
      fill_in description, with: data.description
      attach_file picture_file, image_dir + file
      select person.name(reversed: true), from: person_person
      click_button save

      expect(page).to have_title person.name(full: false)

      expect(Picture.count).to eq 1
      p = Picture.last

      expect(p.description).to eq data.description
      expect(p.person_id).to eq person.id
      expect(p.image_file_name).to eq file
      expect(p.image_content_type).to eq "image/jpeg"
      expect(p.image_file_size).to eq 13738
    end

    context "failure" do
      let(:file_bad_name) { "malcolm.txt" }
      let(:file_bad_type) { "malcolm.gif" }

      it "bad name" do
        click_link new_picture
        fill_in description, with: data.description
        attach_file picture_file, image_dir + file_bad_name
        select person.name(reversed: true), from: person_person
        click_button save

        expect(page).to have_title new_picture
        expect(Picture.count).to eq 0
        expect(page).to have_css(error, text: "contents")
      end

      it "bad type" do
        click_link new_picture
        fill_in description, with: data.description
        attach_file picture_file, image_dir + file_bad_type
        select person.name(reversed: true), from: person_person
        click_button save

        expect(page).to have_title new_picture
        expect(Picture.count).to eq 0
        expect(page).to have_css(error, text: "contents")
      end
    end
  end

  context "edit" do
    let(:picture) { create(:picture) }

    it "person" do
      expect(picture.person_id).to_not eq person.id

      visit picture_path(picture)
      click_link edit

      expect(page).to have_title edit_picture
      select person.name(reversed: true), from: person_person
      click_button save

      expect(page).to have_title person.name(full: false)

      expect(Picture.count).to eq 1
      p = Picture.last

      expect(p.person_id).to eq person.id
    end

    it "description" do
      expect(picture.description).to be_present

      visit picture_path(picture)
      click_link edit

      expect(page).to have_title edit_picture
      fill_in description, with: ""
      click_button save

      expect(page).to have_title picture.person.name(full: false)

      expect(Picture.count).to eq 1
      p = Picture.last

      expect(p.description).to be_nil
    end
  end

  context "delete" do
    let!(:picture) { create(:picture) }

    it "success" do
      visit picture_path(picture)
      click_link edit
      click_link delete

      expect(page).to have_title picture.person.name(full: false)
      expect(Picture.count).to eq 0
    end
  end
end
