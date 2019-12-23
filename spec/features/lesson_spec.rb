require 'rails_helper'

describe Lesson do
  let(:data)    { build(:lesson) }
  let!(:lesson) { create(:lesson) }

  before(:each) do
    login
    click_link t("lesson.lessons")
  end

  context "create" do
    it "success" do
      click_link t("lesson.new")
      fill_in t("lesson.chapter"), with: data.chapter
      fill_in t("lesson.chapter_no"), with: data.chapter_no
      fill_in t("lesson.complete"), with: data.complete
      fill_in t("lesson.link"), with: data.link
      fill_in t("lesson.book"), with: data.book
      fill_in t("lesson.section"), with: data.section
      fill_in t("lesson.series"), with: data.series
      fill_in t("lesson.eco"), with: data.eco
      click_button t("save")

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
      click_link t("lesson.new")
      fill_in t("lesson.chapter_no"), with: data.chapter_no
      fill_in t("lesson.complete"), with: data.complete
      fill_in t("lesson.link"), with: data.link
      fill_in t("lesson.book"), with: data.book
      fill_in t("lesson.section"), with: data.section
      fill_in t("lesson.series"), with: data.series
      fill_in t("lesson.eco"), with: data.eco
      click_button t("save")

      expect(page).to have_title t("lesson.new")
      expect(Lesson.count).to eq 1
      expect_error(page, "blank")
    end
  end

  context "edit" do
    it "success" do
      visit lesson_path(lesson)
      click_link t("edit")

      expect(page).to have_title t("lesson.edit")
      fill_in t("lesson.chapter"), with: data.chapter
      click_button t("save")

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
      click_link t("edit")
      click_link t("delete")

      expect(page).to have_title t("lesson.lessons")
      expect(Lesson.count).to eq 0
    end
  end
end
