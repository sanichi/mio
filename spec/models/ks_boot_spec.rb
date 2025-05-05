require 'rails_helper'

describe Ks::Boot do
  context "creation" do
    let!(:boot) { create(:ks_boot) }

    it "success" do
      expect(Ks::Boot.count).to eq 1
      expect(Ks::SERVERS).to include(boot.server)
      expect(Ks::Boot::APPS).to include(boot.app)

      expect(Ks::Journal.count).to eq 1
      expect(boot.journal.class).to eq Ks::Journal
      expect(boot.journal.boots.size).to eq 1
      expect(boot.journal.boots_count).to eq 1
      expect(boot.journal.boots.first.id).to eq boot.id

      boot.journal.destroy!
      expect(Ks::Journal.count).to eq 0
      expect(Ks::Boot.count).to eq 0
    end

    context "failure" do
      it "bad server" do
        expect{create(:ks_boot, server: "nhn")}.to raise_error(/Server is not included in the list/)
      end

      it "bad app" do
        expect{create(:ks_boot, app: "test")}.to raise_error(/App is not included in the list/)
      end

      it "no time" do
        expect{create(:ks_boot, happened_at: nil)}.to raise_error(/Happened at can't be blank/)
      end

      it "duplicate" do
        expect{create(:ks_boot, happened_at: boot.happened_at, server: boot.server, app: boot.app)}.to raise_error(/Happened at the same time with the same server and app/)
      end
    end
  end
end
