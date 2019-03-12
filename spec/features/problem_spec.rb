require 'rails_helper'

describe Problem do
  let(:data)     { build(:problem) }
  let!(:problem) { create(:problem) }

  before(:each) do
    login
    click_link t(:problem_problems)
  end

  context "create" do
    it "success" do
      click_link t(:problem_new)
      select I18n.t("problem.levels")[data.level], from: t(:problem_level)
      select I18n.t("problem.categories", locale: "jp")[data.category], from: t(:problem_category)
      select I18n.t("problem.subcategories", locale: "jp")[data.subcategory], from: t(:problem_subcategory)
      fill_in t(:problem_note), with: data.note
      click_button t(:save)

      expect(page).to have_title data.description

      expect(Problem.count).to eq 2
      p = Problem.last

      expect(p.level).to eq data.level
      expect(p.category).to eq data.category
      expect(p.subcategory).to eq data.subcategory
      expect(p.note).to eq data.note
    end

    it "failure" do
      click_link t(:problem_new)
      select I18n.t("problem.levels")[data.level], from: t(:problem_level)
      select I18n.t("problem.categories", locale: "jp")[data.category], from: t(:problem_category)
      fill_in t(:problem_note), with: data.note
      click_button t(:save)

      expect(page).to have_title t(:problem_new)
      expect(Problem.count).to eq 1
      expect(page).to have_css(error, text: "not a number")
    end
  end

  context "edit" do
    it "success" do
      visit problem_path(problem)
      click_link t(:edit)

      expect(page).to have_title t(:problem_edit)
      select I18n.t("problem.subcategories", locale: "jp")[data.subcategory], from: t(:problem_subcategory)
      click_button t(:save)

      expect(page).to have_title problem.yield_self{ |p| p.subcategory = data.subcategory; p }.description

      expect(Problem.count).to eq 1
      p = Problem.last

      expect(p.subcategory).to eq data.subcategory
    end
  end

  context "delete" do
    it "success" do
      expect(Problem.count).to eq 1

      visit problem_path(problem)
      click_link t(:edit)
      click_link t(:delete)

      expect(page).to have_title t(:problem_problems)
      expect(Problem.count).to eq 0
    end
  end
end
