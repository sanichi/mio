require 'rails_helper'

describe Expense do
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
      click_link t("expense.new")
      fill_in t("description"), with: data.description
      select category, from: t("expense.category.category")
      select period, from: t("expense.period.period")
      fill_in t("amount"), with: data.amount
      click_button t("save")

      expect(page).to have_title t("expense.expenses")
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
      click_link t("expense.new")
      select category, from: t("expense.category.category")
      select period, from: t("expense.period.period")
      fill_in t("amount"), with: data.amount
      click_button t("save")

      expect(page).to have_title t("expense.new")
      expect(Expense.count).to eq 0
      expect_error(page, "blank")
    end

    it "invalid amount" do
      click_link t("expense.new")
      fill_in t("description"), with: data.description
      select category, from: t("expense.category.category")
      select period, from: t("expense.period.period")
      fill_in t("amount"), with: "0.0"
      click_button t("save")

      expect(page).to have_title t("expense.new")
      expect(Expense.count).to eq 0
      expect_error(page, "greater than 0")
    end
  end

  context "edit" do
    let!(:expense) { create(:expense, period: "year") }

    it "success" do
      visit expenses_path
      click_link t("edit")

      expect(page).to have_title t("expense.edit")
      select period, from: t("expense.period.period")
      click_button t("save")

      expect(page).to have_title t("expense.expenses")

      expect(Expense.count).to eq 1
      e = Expense.first

      expect(e.period).to eq data.period
    end
  end

  context "delete" do
    let!(:expense) { create(:expense) }

    it "success" do
      visit expenses_path
      click_link t("edit")
      click_link t("delete")

      expect(page).to have_title t("expense.expenses")
      expect(Expense.count).to eq 0
    end
  end
end
