require 'rails_helper'

describe Trade do
  let(:data)   { build(:trade) }
  let!(:trade) { create(:trade) }

  before(:each) do
    login
    click_link t(:trade_trades)
  end

  context "create" do
    it "success" do
      click_link t(:trade_new)
      fill_in t(:trade_stock), with: data.stock
      fill_in t(:trade_units), with: data.units
      fill_in t(:trade_buy__date), with: data.buy_date
      fill_in t(:trade_buy__price), with: data.buy_price
      fill_in t(:trade_sell__date), with: data.sell_date
      fill_in t(:trade_sell__price), with: data.sell_price
      click_button t(:save)

      expect(page).to have_title data.stock

      expect(Trade.count).to eq 2
      t = Trade.last

      expect(t.stock).to eq data.stock
      expect(t.units).to eq data.units
      expect(t.buy_date).to eq data.buy_date
      expect(t.buy_price).to eq data.buy_price
      expect(t.sell_date).to eq data.sell_date
      expect(t.sell_price).to eq data.sell_price
    end

    it "failure" do
      click_link t(:trade_new)
      fill_in t(:trade_stock), with: data.stock
      fill_in t(:trade_units), with: data.units
      fill_in t(:trade_buy__date), with: data.sell_date
      fill_in t(:trade_buy__price), with: data.buy_price
      fill_in t(:trade_sell__date), with: data.buy_date
      fill_in t(:trade_sell__price), with: data.sell_price
      click_button t(:save)

      expect(page).to have_title t(:trade_new)
      expect(Trade.count).to eq 1
      expect(page).to have_css(error, text: "before")
    end
  end

  context "edit" do
    context "success" do
      it "stock" do
        click_link trade.stock
        click_link t(:edit)

        expect(page).to have_title t(:trade_edit)
        fill_in t(:trade_stock), with: data.stock
        click_button t(:save)

        expect(page).to have_title data.stock

        expect(Trade.count).to eq 1
        t = Trade.last

        expect(t.stock).to eq data.stock
      end

      it "sell price" do
        click_link trade.stock
        click_link t(:edit)

        expect(page).to have_title t(:trade_edit)
        fill_in t(:trade_sell__price), with: trade.buy_price
        click_button t(:save)

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
      click_link t(:edit)

      fill_in t(:trade_stock), with: ""
      click_button t(:save)

      expect(page).to have_title t(:trade_edit)
      expect(Trade.count).to eq 1
      expect(page).to have_css(error, text: "blank")
    end
  end

  context "delete" do
    it "success" do
      expect(Trade.count).to eq 1

      click_link trade.stock
      click_link t(:edit)
      click_link t(:delete)

      expect(page).to have_title t(:trade_trades)
      expect(Trade.count).to eq 0
    end
  end
end
