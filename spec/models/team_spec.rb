require 'rails_helper'

describe Team do

  context "results", live: true do
    let!(:team) { create(:team, slug: "manchester-city") }

    it "month" do
      today = Date.today
      results =
        case today.month
        when 6
          team.monthResults("#{today.year}-05")
        when 7
          team.monthResults("#{today.year}-08")
        else
          team.monthResults
        end
      expect(results).to be_a(Array)
      results.each do |r|
        expect(r).to be_a(Hash)
        expect(r[:home_team]).to be_present
        expect(r[:away_team]).to be_present
        expect(r[:date]).to be_a(Date)
        score = "#{r[:home_score]}-#{r[:away_score]}"
        expect(score).to match(/\A(-|1?\d-1?\d)\z/)
      end
    end

    it "season" do
      results = team.seasonResults
      expect(results).to be_a(Array)
      expect(results).to_not be_empty
      results.each do |r|
        expect(r).to be_a(Hash)
        expect(r[:home_team]).to be_present
        expect(r[:away_team]).to be_present
        expect(r[:date]).to be_a(Date)
        score = "#{r[:home_score]}-#{r[:away_score]}"
        expect(score).to match(/\A(-|1?\d-1?\d)\z/)
      end
    end
  end
end
