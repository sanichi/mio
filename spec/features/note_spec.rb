require 'rails_helper'

describe Note do
  let(:data)  { build(:note) }
  let!(:note) { create(:note) }

  before(:each) do
    login
    click_link t("note.notes")
  end

  context "create" do
    it "success" do
      click_link t("note.new")
      fill_in t("note.title"), with: data.title
      fill_in t("note.stuff"), with: data.stuff
      fill_in t("note.series"), with: data.series
      fill_in t("note.number"), with: data.number
      click_button t("save")

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
      click_link t("note.new")
      fill_in t("note.stuff"), with: data.stuff
      click_button t("save")

      expect(page).to have_title t("note.new")
      expect(Note.count).to eq 1
      expect_error(page, "blank")
    end
  end

  context "edit" do
    it "change title" do
      visit note_path(note)
      click_link t("edit")

      expect(page).to have_title t("note.edit")
      fill_in t("note.title"), with: data.title
      click_button t("save")

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
      click_link t("edit")
      click_link t("delete")

      expect(page).to have_title t("note.notes")
      expect(Note.count).to eq 0
    end
  end

  context "number shift" do
    let(:s) { Faker::Lorem.sentence.truncate(Note::MAX_SERIES) }
    let!(:a1) { create(:note, series: s, number: 1) }
    let!(:a2) { create(:note, series: s, number: 2) }
    let!(:a3) { create(:note, series: s, number: 3) }
    let!(:a4) { create(:note, series: s, number: 4) }

    it "first to last" do
      visit note_path(a1)
      click_link t("note.shift")
      select t("note.last"), from: t("note.shift")
      click_button t("save")

      [a1, a2, a3, a4].each { |n| n.reload }

      expect(a1.number).to eq 4
      expect(a2.number).to eq 1
      expect(a3.number).to eq 2
      expect(a4.number).to eq 3
    end

    it "last to first" do
      visit note_path(a4)
      click_link t("note.shift")
      select a1.ntitle, from: t("note.shift")
      click_button t("save")

      [a1, a2, a3, a4].each { |n| n.reload }

      expect(a1.number).to eq 2
      expect(a2.number).to eq 3
      expect(a3.number).to eq 4
      expect(a4.number).to eq 1
    end

    it "2nd to 2nd last" do
      visit note_path(a2)
      click_link t("note.shift")
      select a4.ntitle, from: t("note.shift")
      click_button t("save")

      [a1, a2, a3, a4].each { |n| n.reload }

      expect(a1.number).to eq 1
      expect(a2.number).to eq 3
      expect(a3.number).to eq 2
      expect(a4.number).to eq 4
    end

    it "2nd last to 2nd" do
      visit note_path(a3)
      click_link t("note.shift")
      select a2.ntitle, from: t("note.shift")
      click_button t("save")

      [a1, a2, a3, a4].each { |n| n.reload }

      expect(a1.number).to eq 1
      expect(a2.number).to eq 3
      expect(a3.number).to eq 2
      expect(a4.number).to eq 4
    end

    it "last to last" do
      visit note_path(a4)
      click_link t("note.shift")
      select t("note.last"), from: t("note.shift")
      click_button t("save")

      [a1, a2, a3, a4].each { |n| n.reload }

      expect(a1.number).to eq 1
      expect(a2.number).to eq 2
      expect(a3.number).to eq 3
      expect(a4.number).to eq 4
    end
  end
end
