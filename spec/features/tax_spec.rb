require 'rails_helper'

describe Tax do
  let(:data) { build(:tax) }
  let!(:tax) { create(:tax) }

  before(:each) do
    login
    click_link t(:tax_taxes)
  end

  context "create" do
    context "success" do
      it "normal" do
        click_link t(:tax_new)
        fill_in t(:description), with: data.description
        fill_in t(:tax_free), with: data.free
        fill_in t(:tax_income), with: data.income
        fill_in t(:tax_paid), with: data.paid
        fill_in t(:tax_times), with: data.times
        select data.tax_year, from: t(:tax_year)
        click_button t(:save)

        expect(page).to have_title data.description

        expect(Tax.count).to eq 2
        t = Tax.last

        expect(t.description).to eq data.description
        expect(t.free).to eq data.free
        expect(t.income).to eq data.income
        expect(t.paid).to eq data.paid
        expect(t.times).to eq data.times
        expect(t.year_number).to eq data.year_number
      end
    end

    context "failure" do
      it "duplicate description/year" do
        click_link t(:tax_new)
        fill_in t(:description), with: tax.description
        fill_in t(:tax_free), with: data.free
        fill_in t(:tax_income), with: data.income
        fill_in t(:tax_paid), with: data.paid
        fill_in t(:tax_times), with: data.times
        select tax.tax_year, from: t(:tax_year)
        click_button t(:save)

        expect(page).to have_title t(:tax_new)
        expect(page).to have_css(error, text: "taken")

        expect(Tax.count).to eq 1
      end
    end
  end

  context "edit" do
    context "success" do
      it "description" do
        click_link tax.description
        click_link t(:edit)

        expect(page).to have_title t(:tax_edit)

        fill_in t(:description), with: data.description
        click_button t(:save)

        expect(page).to have_title data.description

        expect(Tax.count).to eq 1
        t = Tax.last

        expect(t.description).to eq data.description
      end
    end

    context "failure" do
      it "income" do
        click_link tax.description
        click_link t(:edit)

        fill_in t(:tax_income), with: "0"
        click_button t(:save)

        expect(page).to have_title t(:tax_edit)
        expect(page).to have_css(error, text: "greater than")
      end
    end
  end

  context "delete" do
    it "success" do
      expect(Tax.count).to eq 1

      click_link tax.description
      click_link t(:edit)
      click_link t(:delete)

      expect(page).to have_title t(:tax_taxes)
      expect(Tax.count).to eq 0
    end
  end
end
