require 'rails_helper'

describe Income do
  include_context "test_data"

  let(:data)     { build(:income) }
  let(:category) { I18n.t("income.category.#{data.category}") }
  let(:period)   { I18n.t("income.period.#{data.period}") }

  let(:table) { "//table/tbody/tr[td[.='%s'] and td[.='%s'] and td[.='%s'] and td[.='%s'] and td[.='%s'] and td[.='%s']]" }
  let(:error) { "div.help-block" }

  before(:each) do
    login
    visit incomes_path
  end

  context "create" do
    it "success" do
      click_link new_income
      fill_in description, with: data.description
      select category, from: income_category
      select period, from: income_period
      fill_in amount, with: data.amount
      fill_in income_start, with: data.start.to_s(:db)
      click_button save

      expect(page).to have_title incomes
      expect(page).to have_xpath table % [data.description, category, period, "%.2f" % data.amount, data.annual, data.start.to_s(:db)]

      expect(Income.count).to eq 1
      e = Income.first

      expect(e.description).to eq data.description
      expect(e.category).to eq data.category
      expect(e.period).to eq data.period
      expect(e.amount).to eq data.amount
      expect(e.annual).to eq data.annual
      expect(e.start).to eq data.start
      expect(e.finish).to be_nil
    end
  end

  context "failure" do
    it "no decription" do
      click_link new_income
      select category, from: income_category
      select period, from: income_period
      fill_in amount, with: data.amount
      click_button save

      expect(page).to have_title new_income
      expect(Income.count).to eq 0
      expect(page).to have_css(error, text: "blank")
    end

    it "invalid amount" do
      click_link new_income
      fill_in description, with: data.description
      select category, from: income_category
      select period, from: income_period
      fill_in amount, with: "-1000.0"
      click_button save

      expect(page).to have_title new_income
      expect(Income.count).to eq 0
      expect(page).to have_css(error, text: "greater than 0")
    end
  end

  context "edit" do
    let!(:income) { create(:income, category: "sandra") }

    it "success" do
      visit incomes_path
      click_link edit

      expect(page).to have_title edit_income
      select category, from: income_category
      click_button save

      expect(page).to have_title incomes

      expect(Income.count).to eq 1
      e = Income.first

      expect(e.category).to eq data.category
    end
  end

  context "delete" do
    let!(:income) { create(:income) }

    it "success" do
      visit incomes_path
      click_link edit
      click_link delete

      expect(page).to have_title incomes
      expect(Income.count).to eq 0
    end
  end
end
