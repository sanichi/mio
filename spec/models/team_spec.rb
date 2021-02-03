require 'rails_helper'

describe Team do

  context "results", live: true do
    let!(:team) { create(:team, slug: "manchester-city") }

    it "month" do
      results = team.monthResults
      expect(results).to be_a(Array)
      results.each do |r|
        expect(r[:home]).to be_present
        expect(r[:away]).to be_present
        expect(r[:date]).to be_a(Date)
        expect(r[:score]).to match(/\A(-|1?\d-1?\d)\z/)
      end
    end

    it "season" do
      results = team.seasonResults
      expect(results).to be_a(Array)
      expect(results).to_not be_empty
      results.each do |r|
        expect(r[:home]).to be_present
        expect(r[:away]).to be_present
        expect(r[:date]).to be_a(Date)
        expect(r[:score]).to match(/\A(-|1?\d-1?\d)\z/)
      end
    end
  end
end
