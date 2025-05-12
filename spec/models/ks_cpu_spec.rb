require 'rails_helper'

describe Ks::Cpu do
  context "creation" do
    let!(:cpu) { create(:ks_cpu) }

    it "success" do
      expect(Ks::Cpu.count).to eq 1
      expect(Ks::SERVERS).to include(cpu.server)

      expect(Ks::Journal.count).to eq 1
      expect(cpu.journal.class).to eq Ks::Journal
      expect(cpu.journal.cpus.size).to eq 1
      expect(cpu.journal.cpus_count).to eq 1
      expect(cpu.journal.cpus.first.id).to eq cpu.id

      cpu.journal.destroy!
      expect(Ks::Journal.count).to eq 0
      expect(Ks::Cpu.count).to eq 0
    end

    context "failure" do
      it "bad server" do
        expect{create(:ks_cpu, server: "str")}.to raise_error(/Server is not included in the list/)
      end

      it "no time" do
        expect{create(:ks_cpu, measured_at: nil)}.to raise_error(/Measured at can't be blank/)
      end

      it "duplicate" do
        expect{create(:ks_cpu, measured_at: cpu.measured_at, server: cpu.server)}.to raise_error(/Measured at the same time with the same server/)
      end
    end
  end
end
