require 'rails_helper'

describe Income do
  let(:data)     { build(:income) }
  let(:category) { I18n.t("income.category.#{data.category}") }
  let(:period)   { I18n.t("income.period.#{data.period}") }

  before(:each) do
    login
    visit incomes_path
  end

  context "create" do
    it "success" do
      click_link t("income.new")
      fill_in t("description"), with: data.description
      select category, from: t("income.category.category")
      select period, from: t("income.period.period")
      fill_in t("amount"), with: data.amount
      fill_in t("income.joint"), with: data.joint
      fill_in t("income.start"), with: data.start.to_s(:db)
      click_button t("save")

      expect(page).to have_title t("income.incomes")

      expect(Income.count).to eq 1
      e = Income.first

      expect(e.description).to eq data.description
      expect(e.category).to eq data.category
      expect(e.period).to eq data.period
      expect(e.amount).to eq data.amount
      expect(e.joint).to eq data.joint
      expect(e.annual).to eq data.annual
      expect(e.start).to eq data.start
      expect(e.finish).to be_nil
    end
  end

  context "failure" do
    it "no decription" do
      click_link t("income.new")
      select category, from: t("income.category.category")
      select period, from: t("income.period.period")
      fill_in t("amount"), with: data.amount
      click_button t("save")

      expect(page).to have_title t("income.new")
      expect(Income.count).to eq 0
      expect_error(page, "blank")
    end

    it "invalid amount" do
      click_link t("income.new")
      fill_in t("description"), with: data.description
      select category, from: t("income.category.category")
      select period, from: t("income.period.period")
      fill_in t("amount"), with: "-1000.0"
      click_button t("save")

      expect(page).to have_title t("income.new")
      expect(Income.count).to eq 0
      expect_error(page, "greater than 0")
    end
  end

  context "edit" do
    let!(:income) { create(:income, category: "sandra") }

    it "success" do
      visit incomes_path
      click_link t("edit")

      expect(page).to have_title t("income.edit")
      select category, from: t("income.category.category")
      click_button t("save")

      expect(page).to have_title t("income.incomes")

      expect(Income.count).to eq 1
      e = Income.first

      expect(e.category).to eq data.category
    end
  end

  context "delete" do
    let!(:income) { create(:income) }

    it "success" do
      visit incomes_path
      click_link t("edit")
      click_link t("delete")

      expect(page).to have_title t("income.incomes")
      expect(Income.count).to eq 0
    end
  end
end
