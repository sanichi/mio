require 'rails_helper'

describe Team do

  context "results", live: true do
    let!(:team) { create(:team, slug: "manchester-city") }

    it "succeeds" do
      results = team.results
      expect(results).to be_a(Array)
      results.each do |r|
        puts r.keys
      end
    end
  end
end
