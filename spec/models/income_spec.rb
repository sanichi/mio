require 'rails_helper'

describe Income do
  context "annual" do
    let(:year_25) { create(:income, description: "Test 1", amount: 40000.0, period: "year", joint: 25) }
    let(:mon_100) { create(:income, description: "Test 2", amount: 1000.0, period: "month", joint: 100) }
    let(:week_50) { create(:income, description: "Test 3", amount: 400.0, period: "week", joint: 50) }
    let(:year_00) { create(:income, description: "Test 4", amount: 20000.0, period: "year", joint: 0) }

    it "joint" do
      expect(year_25.annual(joint: true)).to eq 10000.0
      expect(mon_100.annual(joint: true)).to eq 12000.0
      expect(week_50.annual(joint: true)).to eq 10400.0
      expect(year_00.annual(joint: true)).to eq 0.0
    end

    it "total" do
      expect(year_25.annual(joint: false)).to eq 40000.0
      expect(mon_100.annual(joint: false)).to eq 12000.0
      expect(week_50.annual(joint: false)).to eq 20800.0
      expect(year_00.annual(joint: false)).to eq 20000.0
    end

    it "default (t(:income_joint))" do
      expect(year_25.annual).to eq year_25.annual(joint: true)
      expect(mon_100.annual).to eq mon_100.annual(joint: true)
      expect(week_50.annual).to eq week_50.annual(joint: true)
      expect(year_00.annual).to eq year_00.annual(joint: true)
    end
  end
end
