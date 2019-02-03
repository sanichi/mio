require 'rails_helper'

describe Book do
  let(:data)  { build(:book) }
  let!(:book) { create(:book) }

  before(:each) do
    login
    click_link t(:book_books)
  end

  context "create" do
    it "success" do
      click_link t(:book_new)
      fill_in t(:book_title), with: data.title
      fill_in t(:book_author), with: data.author
      fill_in t(:book_year), with: data.year
      select I18n.t("book.categories.#{data.category}"), from: t(:book_category)
      select I18n.t("book.media.#{data.medium}"), from: t(:book_medium)
      fill_in t(:note), with: data.note
      click_button t(:save)

      expect(page).to have_title data.title

      expect(Book.count).to eq 2
      b = Book.last

      expect(b.title).to eq data.title
      expect(b.author).to eq data.author
      expect(b.year).to eq data.year
      expect(b.category).to eq data.category
      expect(b.medium).to eq data.medium
      expect(b.note).to eq data.note
    end

    it "failure" do
      click_link t(:book_new)
      fill_in t(:book_author), with: data.author
      fill_in t(:book_year), with: data.year
      select I18n.t("book.categories.#{data.category}"), from: t(:book_category)
      select I18n.t("book.media.#{data.medium}"), from: t(:book_medium)
      fill_in t(:note), with: data.note
      click_button t(:save)

      expect(page).to have_title t(:book_new)
      expect(Book.count).to eq 1
      expect(page).to have_css(error, text: "blank")
    end
  end

  context "edit" do
    it "success" do
      click_link book.title
      click_link t(:edit)

      expect(page).to have_title t(:book_edit)
      fill_in t(:book_title), with: data.title
      click_button t(:save)

      expect(page).to have_title data.title

      expect(Book.count).to eq 1
      b = Book.last

      expect(b.title).to eq data.title
    end

    it "failure" do
      click_link book.title
      click_link t(:edit)

      fill_in t(:book_author), with: ""
      click_button t(:save)

      expect(page).to have_title t(:book_edit)
      expect(page).to have_css(error, text: "blank")
    end
  end

  context "delete" do
    it "success" do
      expect(Book.count).to eq 1

      click_link book.title
      click_link t(:edit)
      click_link t(:delete)

      expect(page).to have_title t(:book_library)
      expect(Book.count).to eq 0
    end
  end
end
