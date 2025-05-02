require 'rails_helper'

DF = "%Y-%m-%d %H:%M:%S"

describe Ks do
  context "import" do
    it "1" do
      Ks.setup_test(1)
      journal = Ks.import
      expect(Ks::Journal.count).to eq 1
      expect(journal.note).to_not match(/ERROR/)
      expect(journal.note).to_not match(/WARNING/)
      expect(journal.okay).to be true

      expect(Ks::Boot.count).to eq 16

      expect(Ks::Boot.where(app: "reboot").count).to eq 3
      expect(Ks::Boot.where(app: "reboot", server: "hok").count).to eq 1
      expect(Ks::Boot.where(app: "reboot", server: "mor").count).to eq 1
      expect(Ks::Boot.where(app: "reboot", server: "tsu").count).to eq 1
      expect(Ks::Boot.where(app: "reboot").descending.first.happened_at.strftime(DF)).to eq "2025-04-09 13:48:16"
      expect(Ks::Boot.where(app: "reboot").descending.last.happened_at.strftime(DF)).to eq "2025-04-09 13:32:59"

      expect(Ks::Boot.where.not(app: "reboot").count).to eq 13
      expect(Ks::Boot.where.not(app: "reboot").where(server: "hok").count).to eq 1
      expect(Ks::Boot.where.not(app: "reboot").where(server: "mor").count).to eq 11
      expect(Ks::Boot.where.not(app: "reboot").where(server: "tsu").count).to eq 1
      expect(Ks::Boot.where.not(app: "reboot").descending.first.happened_at.strftime(DF)).to eq "2025-04-28 16:10:32"
      expect(Ks::Boot.where.not(app: "reboot").descending.last.happened_at.strftime(DF)).to eq "2025-04-25 14:36:09"
      expect(Ks::Boot.where(app: "mio").count).to eq 2
      expect(Ks::Boot.where(app: "tmp").count).to eq 2

      Ks::SERVERS.each do |server|
        expect(Ks::BASE + server + "boot.log").to_not be_file
        expect(Ks::BASE + server + "boot.tmp").to be_file
        expect(Ks::BASE + server + "app.log").to_not be_file
        expect(Ks::BASE + server + "app.tmp").to be_file
      end
    end
  end
end
