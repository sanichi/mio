require 'rails_helper'

describe Trade do
  let(:data)   { build(:trade) }
  let!(:trade) { create(:trade) }

  before(:each) do
    login
    click_link t("trade.trades")
  end

  context "create" do
    it "success" do
      click_link t("trade.new")
      fill_in t("trade.stock"), with: data.stock
      fill_in t("trade.units"), with: data.units
      fill_in t("trade.buy_date"), with: data.buy_date
      fill_in t("trade.buy_price"), with: data.buy_price
      fill_in t("trade.buy_factor"), with: data.buy_factor
      fill_in t("trade.sell_date"), with: data.sell_date
      fill_in t("trade.sell_price"), with: data.sell_price
      fill_in t("trade.sell_factor"), with: data.sell_factor
      click_button t("save")

      expect(page).to have_title data.stock

      expect(Trade.count).to eq 2
      t = Trade.last

      expect(t.stock).to eq data.stock
      expect(t.units).to eq data.units
      expect(t.buy_date).to eq data.buy_date
      expect(t.buy_factor).to eq data.buy_factor
      expect(t.buy_price).to eq data.buy_price
      expect(t.sell_date).to eq data.sell_date
      expect(t.sell_factor).to eq data.sell_factor
      expect(t.sell_price).to eq data.sell_price
    end

    it "failure" do
      click_link t("trade.new")
      fill_in t("trade.stock"), with: data.stock
      fill_in t("trade.units"), with: data.units
      fill_in t("trade.buy_date"), with: data.sell_date
      fill_in t("trade.buy_price"), with: data.buy_price
      fill_in t("trade.buy_factor"), with: data.buy_factor
      fill_in t("trade.sell_date"), with: data.buy_date
      fill_in t("trade.sell_price"), with: data.sell_price
      fill_in t("trade.sell_factor"), with: data.sell_factor
      click_button t("save")

      expect(page).to have_title t("trade.new")
      expect(Trade.count).to eq 1
      expect(page).to have_css(error, text: "before")
    end
  end

  context "edit" do
    context "success" do
      it "stock" do
        click_link trade.stock
        click_link t("edit")

        expect(page).to have_title t("trade.edit")
        fill_in t("trade.stock"), with: data.stock
        click_button t("save")

        expect(page).to have_title data.stock

        expect(Trade.count).to eq 1
        t = Trade.last

        expect(t.stock).to eq data.stock
      end

      it "sell price" do
        click_link trade.stock
        click_link t("edit")

        expect(page).to have_title t("trade.edit")
        fill_in t("trade.sell_price"), with: trade.buy_price
        click_button t("save")

        expect(page).to have_title trade.stock

        expect(Trade.count).to eq 1
        t = Trade.last

        expect(t.sell_price).to eq t.buy_price
        expect(t.profit).to eq 0.0
        expect(t.growth_rate).to eq 0.0
      end
    end

    it "failure" do
      click_link trade.stock
      click_link t("edit")

      fill_in t("trade.stock"), with: ""
      click_button t("save")

      expect(page).to have_title t("trade.edit")
      expect(Trade.count).to eq 1
      expect(page).to have_css(error, text: "blank")
    end
  end

  context "delete" do
    it "success" do
      expect(Trade.count).to eq 1

      click_link trade.stock
      click_link t("edit")
      click_link t("delete")

      expect(page).to have_title t("trade.trades")
      expect(Trade.count).to eq 0
    end
  end
end
