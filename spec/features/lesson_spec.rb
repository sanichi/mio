require 'rails_helper'

describe Lesson do
  let(:data)    { build(:lesson) }
  let!(:lesson) { create(:lesson) }

  before(:each) do
    login
    click_link t(:lesson_lessons)
  end

  context "create" do
    it "success" do
      click_link t(:lesson_new)
      fill_in t(:lesson_chapter), with: data.chapter
      fill_in t(:lesson_chapter__no), with: data.chapter_no
      fill_in t(:lesson_complete), with: data.complete
      fill_in t(:lesson_link), with: data.link
      fill_in t(:lesson_book), with: data.book
      fill_in t(:lesson_section), with: data.section
      fill_in t(:lesson_series), with: data.series
      fill_in t(:lesson_eco), with: data.eco
      click_button t(:save)

      expect(page).to have_title data.chapter

      expect(Lesson.count).to eq 2
      l = Lesson.last

      expect(l.chapter).to eq data.chapter
      expect(l.chapter_no).to eq data.chapter_no
      expect(l.complete).to eq data.complete
      expect(l.link).to eq data.link
      expect(l.book).to eq data.book
      expect(l.section).to eq data.section
      expect(l.series).to eq data.series
      expect(l.eco).to eq data.eco
    end

    it "failure" do
      click_link t(:lesson_new)
      fill_in t(:lesson_chapter__no), with: data.chapter_no
      fill_in t(:lesson_complete), with: data.complete
      fill_in t(:lesson_link), with: data.link
      fill_in t(:lesson_book), with: data.book
      fill_in t(:lesson_section), with: data.section
      fill_in t(:lesson_series), with: data.series
      fill_in t(:lesson_eco), with: data.eco
      click_button t(:save)

      expect(page).to have_title t(:lesson_new)
      expect(Lesson.count).to eq 1
      expect(page).to have_css(error, text: "blank")
    end
  end

  context "edit" do
    it "success" do
      visit lesson_path(lesson)
      click_link t(:edit)

      expect(page).to have_title t(:lesson_edit)
      fill_in t(:lesson_chapter), with: data.chapter
      click_button t(:save)

      expect(page).to have_title data.chapter

      expect(Lesson.count).to eq 1
      l = Lesson.last

      expect(l.chapter).to eq data.chapter
    end
  end

  context "delete" do
    it "success" do
      expect(Lesson.count).to eq 1

      visit lesson_path(lesson)
      click_link t(:edit)
      click_link t(:delete)

      expect(page).to have_title t(:lesson_lessons)
      expect(Lesson.count).to eq 0
    end
  end
end
