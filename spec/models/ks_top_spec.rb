require 'rails_helper'

describe Ks::Top do
  context "creation" do
    let!(:top) { create(:ks_top) }

    it "success" do
      expect(Ks::Top.count).to eq 1
      expect(Ks::SERVERS).to include(top.server)

      expect(Ks::Journal.count).to eq 1
      expect(top.journal.class).to eq Ks::Journal
      expect(top.journal.tops.size).to eq 1
      expect(top.journal.tops_count).to eq 1
      expect(top.journal.tops.first.id).to eq top.id

      top.journal.destroy!
      expect(Ks::Journal.count).to eq 0
      expect(Ks::Top.count).to eq 0
    end

    context "failure" do
      it "bad server" do
        expect{create(:ks_top, server: "str")}.to raise_error(/Server is not included in the list/)
      end

      it "no time" do
        expect{create(:ks_top, measured_at: nil)}.to raise_error(/Measured at can't be blank/)
      end

      it "duplicate" do
        expect{create(:ks_top, measured_at: top.measured_at, server: top.server)}.to raise_error(/Measured at the same time with the same server/)
      end
    end
  end
end
