require 'rails_helper'

describe Expense do
  include_context "test_data"

  let(:data)     { build(:expense) }
  let(:category) { I18n.t("expense.category.#{data.category}") }
  let(:period)   { I18n.t("expense.period.#{data.period}") }

  let(:table) { "//table/tbody/tr[td[.='%s'] and td[.='%s'] and td[.='%s'] and td[.='%s'] and td[.='%s']]" }

  before(:each) do
    login
    visit expenses_path
  end

  context "create" do
    it "success" do
      click_link new_expense
      fill_in description, with: data.description
      select category, from: expense_category
      select period, from: expense_period
      fill_in amount, with: data.amount
      click_button save

      expect(page).to have_title expenses
      expect(page).to have_xpath table % [data.description, category, period, "%.2f" % data.amount, data.annual]

      expect(Expense.count).to eq 1
      e = Expense.first

      expect(e.description).to eq data.description
      expect(e.category).to eq data.category
      expect(e.period).to eq data.period
      expect(e.amount).to eq data.amount
      expect(e.annual).to eq data.annual
    end
  end

  context "failure" do
    it "no decription" do
      click_link new_expense
      select category, from: expense_category
      select period, from: expense_period
      fill_in amount, with: data.amount
      click_button save

      expect(page).to have_title new_expense
      expect(Expense.count).to eq 0
      expect(page).to have_css(error, text: "blank")
    end
    
    it "invalid amount" do
      click_link new_expense
      fill_in description, with: data.description
      select category, from: expense_category
      select period, from: expense_period
      fill_in amount, with: "0.0"
      click_button save

      expect(page).to have_title new_expense
      expect(Expense.count).to eq 0
      expect(page).to have_css(error, text: "greater than 0")
    end
  end

  context "edit" do
    let!(:expense) { create(:expense, period: "year") }

    it "success" do
      visit expenses_path
      click_link edit

      expect(page).to have_title edit_expense
      select period, from: expense_period
      click_button save

      expect(page).to have_title expenses

      expect(Expense.count).to eq 1
      e = Expense.first

      expect(e.period).to eq data.period
    end
  end

  context "delete" do
    let!(:expense) { create(:expense) }

    it "success" do
      visit expenses_path
      click_link edit
      click_link delete

      expect(page).to have_title expenses
      expect(Expense.count).to eq 0
    end
  end
end
