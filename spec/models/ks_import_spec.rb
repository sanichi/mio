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
      expect(journal.tops_count).to eq 186
      expect(journal.procs_count).to eq 1860
      expect(journal.cpus_count).to eq 182
      expect(journal.pcpus_count).to eq 262
      expect(journal.warnings).to eq 0
      expect(journal.problems).to eq 0
      expect(journal.note).to_not match(/WARNING/)
      expect(journal.note).to_not match(/ERROR/)
      expect(journal.note).to match(/hok\/app\.log\.+ 1/)
      expect(journal.note).to match(/hok\/boot\.log\.+ 1/)
      expect(journal.note).to match(/hok\/mem\.log\.+ 59/)
      expect(journal.note).to match(/hok\/top\.log\.+ 60/)
      expect(journal.note).to match(/hok\/cpu\.log\.+ 60/)
      expect(journal.note).to match(/mor\/app\.log\.+ 11/)
      expect(journal.note).to match(/mor\/boot\.log\.+ 1/)
      expect(journal.note).to match(/mor\/mem\.log\.+ 60/)
      expect(journal.note).to match(/mor\/top\.log\.+ 62/)
      expect(journal.note).to match(/mor\/cpu\.log\.+ 60/)
      expect(journal.note).to match(/tsu\/app\.log\.+ 1/)
      expect(journal.note).to match(/tsu\/boot\.log\.+ 1/)
      expect(journal.note).to match(/tsu\/mem\.log\.+ 61/)
      expect(journal.note).to match(/tsu\/top\.log\.+ 64/)
      expect(journal.note).to match(/tsu\/cpu\.log\.+ 62/)

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

      expect(Ks::Top.count).to eq 186
      expect(Ks::Top.where(server: "hok").count).to eq 60
      expect(Ks::Top.where(server: "mor").count).to eq 62
      expect(Ks::Top.where(server: "tsu").count).to eq 64
      expect(Ks::Top.descending.first.measured_at.strftime(DF)).to eq "2025-04-26 15:03:01"
      expect(Ks::Top.descending.last.measured_at.strftime(DF)).to eq "2025-04-26 14:00:01"

      expect(Ks::Proc.count).to eq 1860
      expect(Ks::Proc.where(short: nil).count).to be <= 811
      expect(Ks::Proc.where(short: "httpd").count).to eq 677
      expect(Ks::Proc.where(short: "mio app").count).to eq 62
      expect(Ks::Proc.where(short: "rek app").count).to eq 60
      expect(Ks::Proc.where(short: "step app").count).to eq 64

      expect(Ks::Cpu.count).to eq 182
      expect(Ks::Cpu.where(server: "hok").count).to eq 60
      expect(Ks::Cpu.where(server: "mor").count).to eq 60
      expect(Ks::Cpu.where(server: "tsu").count).to eq 62
      expect(Ks::Cpu.descending.first.measured_at.strftime(DF)).to eq "2025-05-12 01:01:01"
      expect(Ks::Cpu.descending.last.measured_at.strftime(DF)).to eq "2025-05-11 23:00:01"

      expect(Ks::Pcpu.count).to eq 262
      expect(Ks::Pcpu.where(short: nil).count).to be <= 21
      expect(Ks::Pcpu.where(short: "passenger core").count).to eq 182
      expect(Ks::Pcpu.where(short: "api app").count).to eq 17
      expect(Ks::Pcpu.where(short: "systemd (user)").count).to eq 16
      expect(Ks::Pcpu.where(short: "sj app").count).to eq 2
      expect(Ks::Pcpu.where(pcpu: 0.0).count).to eq 0

      Ks::SERVERS.each do |server|
        Ks::LOGS.each do |log|
          expect(Ks::BASE + server + "#{log}.log").to_not be_file
        end
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
      expect(journal.boots_count).to eq 12
      expect(journal.mems_count).to eq 179
      expect(journal.tops_count).to eq 184
      expect(journal.procs_count).to eq 1840
      expect(journal.warnings).to eq 7
      expect(journal.problems).to eq 9
      expect(journal.note).to match(/WARNING: line 1 of hok\/boot\.log is blank/)
      expect(journal.note).to match(/WARNING: line 2 of hok\/app\.log is blank/)
      expect(journal.note).to match(/WARNING: line 5 of hok\/mem\.log is blank/)
      expect(journal.note).to match(/WARNING: line 31 of hok\/top\.log is blank/)
      expect(journal.note).to match(/WARNING: line 33 \(2025-04-26 14:30:01 1051592...\) of hok\/top\.log is a duplicate/)
      expect(journal.note).to match(/WARNING: line 9 \(2025-04-28 14:31:05 mio\) of mor\/app\.log is a duplicate/)
      expect(journal.note).to match(/WARNING: line 12 \(2025-04-25 14:35:01 1774 845 557 929 115 396\) of mor\/mem\.log is a duplicate/)
      expect(journal.note).to match(/ERROR: line 2 \(corrupt\) of hok\/boot\.log can't be parsed into a date/)
      expect(journal.note).to match(/ERROR: line 3 \(corrupt\) of hok\/boot\.log can't be parsed into a date/)
      expect(journal.note).to match(/ERROR: line 6 \(2025-04-28 14:06:45\) of mor\/app\.log has no app/)
      expect(journal.note).to match(/ERROR: line 12 \(corrupt\) of mor\/app\.log can't be parsed into a date/)
      expect(journal.note).to match(/ERROR: line 1 \(corrupt\) of tsu\/app\.log can't be parsed into a date/)
      expect(journal.note).to match(/ERROR: line 14 \(2025-04-25 14:38:01 corrupt\) of tsu\/mem.log has can't be parsed into 6 numbers/)
      expect(journal.note).to match(/ERROR: line 30 \(corrupt\) of mor\/top\.log can't be parsed into a datetime/)
      expect(journal.note).to match(/ERROR: line 30 \(2025-04-26 14:29:01 926495\|...\) of tsu\/top\.log doesn't appear to have 10 procs/)
      expect(journal.note).to match(/ERROR: line 64 \(2025-04-26 15:03:01 926495\|...\) of tsu\/top\.log doesn't appear to have 10 procs/)

      expect(Ks::Boot.count).to eq 12
      expect(Ks::Boot.where(app: "reboot").count).to eq 1
      expect(Ks::Boot.where(app: "reboot", server: "hok").count).to eq 0
      expect(Ks::Boot.where(app: "reboot", server: "tsu").count).to eq 0
      expect(Ks::Boot.where.not(app: "reboot").count).to eq 11
      expect(Ks::Boot.where.not(app: "reboot").where(server: "mor").count).to eq 10
      expect(Ks::Boot.where.not(app: "reboot").where(server: "tsu").count).to eq 0

      expect(Ks::Mem.count).to eq 179
      expect(Ks::Mem.where(server: "hok").count).to eq 59
      expect(Ks::Mem.where(server: "mor").count).to eq 60
      expect(Ks::Mem.where(server: "tsu").count).to eq 60

      expect(Ks::Top.count).to eq 184
      expect(Ks::Top.where(server: "hok").count).to eq 60
      expect(Ks::Top.where(server: "mor").count).to eq 62
      expect(Ks::Top.where(server: "tsu").count).to eq 62

      expect(Ks::Proc.count).to eq 1840
      expect(Ks::Proc.where(short: nil).count).to be <= 806
      expect(Ks::Proc.where(short: "httpd").count).to eq 669
      expect(Ks::Proc.where(short: "mio app").count).to eq 62
      expect(Ks::Proc.where(short: "rek app").count).to eq 60
      expect(Ks::Proc.where(short: "step app").count).to eq 62

      Ks::SERVERS.each do |server|
        Ks::LOGS.each do |log|
          expect(Ks::BASE + server + "#{log}.log").to_not be_file
        end
      end
    end
  end
end
