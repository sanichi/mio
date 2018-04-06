require 'rails_helper'

describe Misa do
  let(:data)  { build(:misa) }
  let!(:misa) { create(:misa) }

  before(:each) do
    login
    click_link t(:misa_misas)
  end

  context "create" do
    it "success" do
      click_link t(:misa_new)
      select I18n.t("misa.categories.#{data.category}"), from: t(:misa_category)
      data.japanese ? check(:misa_japanese) : uncheck(:misa_japanese)
      if data.long
        fill_in t(:misa_long), with: data.long
      end
      fill_in t(:misa_minutes), with: data.minutes
      fill_in t(:misa_note), with: data.note
      fill_in t(:misa_published), with: data.published
      fill_in t(:misa_short), with: data.short
      fill_in t(:misa_title), with: data.title
      click_button t(:save)

      expect(page).to have_title t(:misa_misa)

      expect(Misa.count).to eq 2
      m = Misa.last

      expect(m.category).to eq data.category
      expect(m.japanese).to eq data.japanese
      expect(m.long).to eq data.long
      expect(m.minutes).to eq data.minutes
      expect(m.note).to eq data.note
      expect(m.published).to eq data.published
      expect(m.short).to eq data.short
      expect(m.title).to eq data.title
    end
  end

  context "failure" do
    it "no title" do
      click_link t(:misa_new)
      select I18n.t("misa.categories.#{data.category}"), from: t(:misa_category)
      data.japanese ? check(:misa_japanese) : uncheck(:misa_japanese)
      if data.long
        fill_in t(:misa_long), with: data.long
      end
      fill_in t(:misa_minutes), with: data.minutes
      fill_in t(:misa_note), with: data.note
      fill_in t(:misa_published), with: data.published
      fill_in t(:misa_short), with: data.short
      click_button t(:save)

      expect(page).to have_title t(:misa_new)
      expect(Misa.count).to eq 1
      expect(page).to have_css(error, text: "blank")
    end
  end

  context "edit" do
    it "change title" do
      visit misa_path(misa)
      click_link t(:edit)

      expect(page).to have_title t(:misa_edit)
      fill_in t(:misa_title), with: data.title
      click_button t(:save)

      expect(page).to have_title t(:misa_misa)

      expect(Misa.count).to eq 1
      m = Misa.last

      expect(m.title).to eq data.title
    end
  end

  context "delete" do
    it "success" do
      expect(Misa.count).to eq 1

      visit misa_path(misa)
      click_link t(:edit)
      click_link t(:delete)

      expect(page).to have_title t(:misa_misas)
      expect(Misa.count).to eq 0
    end
  end
end
