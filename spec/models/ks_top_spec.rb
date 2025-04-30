require 'rails_helper'

describe Ks::Top do
  context "creation" do
    let!(:top) { create(:ks_top) }

    it "success" do
      expect(Ks::Top.count).to eq 1
      expect(Ks::SERVERS).to include(top.server)
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
