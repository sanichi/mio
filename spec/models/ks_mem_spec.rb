require 'rails_helper'

describe Ks::Mem do
  context "creation" do
    let!(:mem) { create(:ks_mem) }

    it "success" do
      expect(Ks::Mem.count).to eq 1
      expect(Ks::SERVERS).to include(mem.server)
    end

    context "failure" do
      it "bad server" do
        expect{create(:ks_mem, server: "dub")}.to raise_error(/Server is not included in the list/)
      end

      it "no time" do
        expect{create(:ks_mem, measured_at: nil)}.to raise_error(/Measured at can't be blank/)
      end

      it "zero total" do
        expect{create(:ks_mem, total: 0)}.to raise_error(/Total must be greater than 0/)
      end

      it "zero used" do
        expect{create(:ks_mem, used: 0)}.to raise_error(/Used must be greater than 0/)
      end

      it "negative free" do
        expect{create(:ks_mem, free: -1)}.to raise_error(/Free must be greater than or equal to 0/)
      end

      it "negative avail" do
        expect{create(:ks_mem, avail: -1)}.to raise_error(/Avail must be greater than or equal to 0/)
      end

      it "negative swap_used" do
        expect{create(:ks_mem, swap_used: -1)}.to raise_error(/Swap used must be greater than or equal to 0/)
      end

      it "negative swap_free" do
        expect{create(:ks_mem, swap_free: -1)}.to raise_error(/Swap free must be greater than or equal to 0/)
      end

      it "duplicate" do
        expect{create(:ks_mem, measured_at: mem.measured_at, server: mem.server)}.to raise_error(/Measured at the same time with the same server/)
      end
    end
  end
end
