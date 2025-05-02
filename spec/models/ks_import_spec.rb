require 'rails_helper'

DF = "%Y-%m-%d %H:%M:%S"

describe Ks do
  context "success" do
    it "1" do
      Ks.setup_test(1)
      journal = Ks.import
      puts journal.note
      expect(Ks::Journal.count).to eq 1
      expect(journal.okay).to be true
      expect(journal.boot).to eq 16
      expect(journal.mem).to eq 0
      expect(journal.top).to eq 0
      expect(journal.proc).to eq 0
      expect(journal.warnings).to eq 0
      expect(journal.note).to_not match(/WARNING/)
      expect(journal.note).to_not match(/ERROR/)
      expect(journal.note).to match(/hok\/boot\.log\.+ 1/)
      expect(journal.note).to match(/hok\/app\.log\.+ 1/)
      expect(journal.note).to match(/mor\/boot\.log\.+ 1/)
      expect(journal.note).to match(/mor\/app\.log\.+ 11/)
      expect(journal.note).to match(/tsu\/boot\.log\.+ 1/)
      expect(journal.note).to match(/tsu\/app\.log\.+ 1/)
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

  context "warnings" do
    it "2" do
      Ks.setup_test(2)
      journal = Ks.import
      puts journal.note
      expect(Ks::Journal.count).to eq 1
      expect(journal.okay).to be false
      expect(journal.boot).to eq 11
      expect(journal.mem).to eq 0
      expect(journal.top).to eq 0
      expect(journal.proc).to eq 0
      expect(journal.warnings).to eq 4
      expect(journal.note).to match(/WARNING: line 1 of hok\/boot\.log is blank/)
      expect(journal.note).to match(/WARNING: line 2 of hok\/app\.log is blank/)
      expect(journal.note).to match(/WARNING: line 2 \(2025-04-09 13:41:58\) of mor\/boot\.log is a duplicate/)
      expect(journal.note).to match(/WARNING: line 8 \(2025-04-28 14:31:05 mio\) of mor\/app\.log is a duplicate/)
      expect(journal.note).to match(/ERROR: line 2 \(corrupt\) of hok\/boot\.log can't be parsed into a date/)
      expect(journal.note).to match(/ERROR: line 11 \(corrupt\) of mor\/app\.log can't be parsed into a date/)
      expect(journal.note).to match(/ERROR: line 1 \(corrupt\) of tsu\/app\.log can't be parsed into a date/)
      expect(journal.note).to match(/tsu\/boot\.log\.+ -/)
      expect(Ks::Boot.count).to eq 11

      expect(Ks::Boot.where(app: "reboot").count).to eq 1
      expect(Ks::Boot.where(app: "reboot", server: "hok").count).to eq 0
      expect(Ks::Boot.where(app: "reboot", server: "tsu").count).to eq 0

      expect(Ks::Boot.where.not(app: "reboot").count).to eq 10
      expect(Ks::Boot.where.not(app: "reboot").where(server: "mor").count).to eq 9
      expect(Ks::Boot.where.not(app: "reboot").where(server: "tsu").count).to eq 0

      expect(Ks::BASE + "mor" + "app.log").to be_file
      expect(Ks::BASE + "mor" + "app.tmp").to_not be_file
      expect(Ks::BASE + "tsu" + "app.log").to be_file
      expect(Ks::BASE + "tsu" + "app.tmp").to_not be_file
      expect(Ks::BASE + "tsu" + "boot.log").to_not be_file
      expect(Ks::BASE + "tsu" + "boot.tmp").to_not be_file
    end
  end
end
