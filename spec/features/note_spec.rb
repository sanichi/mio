require 'rails_helper'

describe Note do
  let(:data)  { build(:note) }
  let!(:note) { create(:note) }

  before(:each) do
    login
    click_link t(:note_notes)
  end

  context "create" do
    it "success" do
      click_link t(:note_new)
      fill_in t(:note_title), with: data.title
      fill_in t(:note_stuff), with: data.stuff
      fill_in t(:note_series), with: data.series
      fill_in t(:note_number), with: data.number
      click_button t(:save)

      expect(page).to have_title data.title

      expect(Note.count).to eq 2
      n = Note.last

      expect(n.number).to eq (data.series.nil? ? nil : (data.number || 1))
      expect(n.series).to eq data.series
      expect(n.title).to eq data.title
      expect(n.stuff).to eq data.stuff
    end
  end

  context "failure" do
    it "no title" do
      click_link t(:note_new)
      fill_in t(:note_stuff), with: data.stuff
      click_button t(:save)

      expect(page).to have_title t(:note_new)
      expect(Note.count).to eq 1
      expect(page).to have_css(error, text: "blank")
    end
  end

  context "edit" do
    it "change title" do
      visit note_path(note)
      click_link t(:edit)

      expect(page).to have_title t(:note_edit)
      fill_in t(:note_title), with: data.title
      click_button t(:save)

      expect(page).to have_title data.title

      expect(Note.count).to eq 1
      n = Note.last

      expect(n.title).to eq data.title
    end
  end

  context "delete" do
    it "success" do
      expect(Note.count).to eq 1

      visit note_path(note)
      click_link t(:edit)
      click_link t(:delete)

      expect(page).to have_title t(:note_notes)
      expect(Note.count).to eq 0
    end
  end
end
