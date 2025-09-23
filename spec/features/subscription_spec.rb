require 'rails_helper'

describe Subscription, js: true do
  let(:data)          { build(:subscription) }
  let!(:subscription) { create(:subscription) }

  before(:each) do
    login
    click_link t("other")
    click_link t("subscription.subscriptions")
  end

  context "create" do
    it "success" do
      click_link t("subscription.new")
      fill_in t("subscription.payee"), with: data.payee
      fill_in t("subscription.amount"), with: "£#{sprintf('%.2f', data.amount / 100.0)}"
      select data.human_frequency, from: t("subscription.frequency")
      fill_in t("subscription.source"), with: data.source
      data.active ? check(t("subscription.active")) : uncheck(t("subscription.active"))
      click_button t("save")

      expect(page).to have_title data.payee

      expect(Subscription.count).to eq 2
      s = Subscription.find(Subscription.maximum(:id))

      expect(s.payee).to eq data.payee
      expect(s.amount).to eq data.amount
      expect(s.frequency).to eq data.frequency
      expect(s.source).to eq data.source
      expect(s.active).to eq data.active
    end

    it "failure (no amount)" do
      click_link t("subscription.new")
      fill_in t("subscription.payee"), with: data.payee
      # fill_in t("subscription.amount"), with: "£#{sprintf('%.2f', data.amount / 100.0)}"
      select data.human_frequency, from: t("subscription.frequency")
      fill_in t("subscription.source"), with: data.source
      data.active ? check(t("subscription.active")) : uncheck(t("subscription.active"))
      click_button t("save")

      expect(page).to have_title t("subscription.new")
      expect(Subscription.count).to eq 1
      expect_error(page, "blank")
    end
  end

  context "edit" do
    it "change payee" do
      click_link subscription.payee
      click_link t("edit")

      expect(page).to have_title t("subscription.edit")
      fill_in t("subscription.payee"), with: data.payee
      click_button t("save")

      expect(page).to have_title data.payee

      expect(Subscription.count).to eq 1
      s = Subscription.last

      expect(s.payee).to eq data.payee
      expect(s.frequency).to eq subscription.frequency # there used to be a here
    end

    it "change active state" do
      subscription.update!(active: true)
      click_link subscription.payee
      
      # Find the cost row and check the span doesn't have strikethrough class
      cost_row = page.find('tr', text: t("subscription.cost"))
      cost_span = cost_row.find('span')
      expect(cost_span[:class]).not_to include('text-decoration-line-through')
      
      # Make it inactive
      click_link t("edit")
      uncheck t("subscription.active")
      click_button t("save")
      
      # Check the span now has strikethrough class
      cost_row = page.find('tr', text: t("subscription.cost"))
      cost_span = cost_row.find('span')
      expect(cost_span[:class]).to include('text-decoration-line-through')
    end
  end

  context "delete" do
    it "success" do
      expect(Subscription.count).to eq 1

      click_link subscription.payee
      click_link t("edit")
      accept_confirm do
        click_link t("delete")
      end

      expect(page).to have_title t("subscription.subscriptions")
      expect(Subscription.count).to eq 0
    end
  end
end
