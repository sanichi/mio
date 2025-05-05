require 'rails_helper'

DF = "%Y-%m-%d %H:%M:%S"

describe Ks do
  context "success" do
    it "1" do
      Ks.setup_test(1)
      journal = Ks.import
      # puts journal.note
      expect(Ks::Journal.count).to eq 1
      expect(journal).to be_okay
      expect(journal.boots_count).to eq 16
      expect(journal.mems_count).to eq 180
      expect(journal.tops_count).to eq 0
      expect(journal.procs_count).to eq 0
      expect(journal.warnings).to eq 0
      expect(journal.problems).to eq 0
      expect(journal.note).to_not match(/WARNING/)
      expect(journal.note).to_not match(/ERROR/)
      expect(journal.note).to match(/hok\/app\.log\.+ 1/)
      expect(journal.note).to match(/hok\/boot\.log\.+ 1/)
      expect(journal.note).to match(/hok\/mem\.log\.+ 59/)
      expect(journal.note).to match(/mor\/app\.log\.+ 11/)
      expect(journal.note).to match(/mor\/boot\.log\.+ 1/)
      expect(journal.note).to match(/mor\/mem\.log\.+ 60/)
      expect(journal.note).to match(/tsu\/app\.log\.+ 1/)
      expect(journal.note).to match(/tsu\/boot\.log\.+ 1/)
      expect(journal.note).to match(/tsu\/mem\.log\.+ 61/)

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

      expect(Ks::Mem.count).to eq 180
      expect(Ks::Mem.where(server: "hok").count).to eq 59
      expect(Ks::Mem.where(server: "mor").count).to eq 60
      expect(Ks::Mem.where(server: "tsu").count).to eq 61
      expect(Ks::Mem.descending.first.measured_at.strftime(DF)).to eq "2025-04-25 15:25:01"
      expect(Ks::Mem.descending.last.measured_at.strftime(DF)).to eq "2025-04-25 14:25:01"
      expect(Ks::Mem.maximum(:total)).to eq 1774
      expect(Ks::Mem.minimum(:total)).to eq 768
      expect(Ks::Mem.maximum(:used)).to eq 951
      expect(Ks::Mem.minimum(:used)).to eq 242
      expect(Ks::Mem.maximum(:free)).to eq 564
      expect(Ks::Mem.minimum(:free)).to eq 175
      expect(Ks::Mem.maximum(:avail)).to eq 935
      expect(Ks::Mem.minimum(:avail)).to eq 399
      expect(Ks::Mem.maximum(:swap_used)).to eq 346
      expect(Ks::Mem.minimum(:swap_used)).to eq 114
      expect(Ks::Mem.maximum(:swap_free)).to eq 397
      expect(Ks::Mem.minimum(:swap_free)).to eq 165

      Ks::SERVERS.each do |server|
        expect(Ks::BASE + server + "app.log").to_not be_file
        expect(Ks::BASE + server + "app.tmp").to be_file
        expect(Ks::BASE + server + "boot.log").to_not be_file
        expect(Ks::BASE + server + "boot.tmp").to be_file
        expect(Ks::BASE + server + "mem.log").to_not be_file
        expect(Ks::BASE + server + "mem.tmp").to be_file
      end
    end
  end

  context "warnings and problems" do
    it "2" do
      Ks.setup_test(2)
      journal = Ks.import
      # puts journal.note
      expect(Ks::Journal.count).to eq 1
      expect(journal).to_not be_okay
      expect(journal.boots_count).to eq 11
      expect(journal.mems_count).to eq 132
      expect(journal.tops_count).to eq 0
      expect(journal.procs_count).to eq 0
      expect(journal.warnings).to eq 5
      expect(journal.problems).to eq 4
      expect(journal.note).to match(/WARNING: line 2 of hok\/app\.log is blank/)
      expect(journal.note).to match(/WARNING: line 1 of hok\/boot\.log is blank/)
      expect(journal.note).to match(/WARNING: line 5 of hok\/mem\.log is blank/)
      expect(journal.note).to match(/WARNING: line 8 \(2025-04-28 14:31:05 mio\) of mor\/app\.log is a duplicate/)
      expect(journal.note).to match(/WARNING: line 12 \(2025-04-25 14:35:01 1774 845 557 929 115 396\) of mor\/mem\.log is a duplicate/)
      expect(journal.note).to match(/ERROR: line 2 \(corrupt\) of hok\/boot\.log can't be parsed into a date/)
      expect(journal.note).to match(/ERROR: line 11 \(corrupt\) of mor\/app\.log can't be parsed into a date/)
      expect(journal.note).to match(/ERROR: line 1 \(corrupt\) of tsu\/app\.log can't be parsed into a date/)
      expect(journal.note).to match(/ERROR: line 14 \(2025-04-25 14:38:01 corrupt\) of tsu\/mem.log has can't be parsed into 6 numbers/)

      expect(Ks::Boot.count).to eq 11
      expect(Ks::Boot.where(app: "reboot").count).to eq 1
      expect(Ks::Boot.where(app: "reboot", server: "hok").count).to eq 0
      expect(Ks::Boot.where(app: "reboot", server: "tsu").count).to eq 0
      expect(Ks::Boot.where.not(app: "reboot").count).to eq 10
      expect(Ks::Boot.where.not(app: "reboot").where(server: "mor").count).to eq 9
      expect(Ks::Boot.where.not(app: "reboot").where(server: "tsu").count).to eq 0

      expect(Ks::Mem.count).to eq 132
      expect(Ks::Mem.where(server: "hok").count).to eq 59
      expect(Ks::Mem.where(server: "mor").count).to eq 60
      expect(Ks::Mem.where(server: "tsu").count).to eq 13

      expect(Ks::BASE + "mor" + "app.log").to be_file
      expect(Ks::BASE + "mor" + "app.tmp").to_not be_file
      expect(Ks::BASE + "tsu" + "app.log").to be_file
      expect(Ks::BASE + "tsu" + "app.tmp").to_not be_file
      expect(Ks::BASE + "tsu" + "boot.log").to_not be_file
      expect(Ks::BASE + "tsu" + "boot.tmp").to_not be_file
      expect(Ks::BASE + "tsu" + "mem.log").to be_file
      expect(Ks::BASE + "tsu" + "mem.tmp").to_not be_file
    end
  end
end
