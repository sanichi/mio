require 'rails_helper'

describe Ks::Cpu do
  context "creation" do
    let!(:cpu) { create(:ks_cpu) }

    context "success" do
      it "create" do
        expect(Ks::Cpu.count).to eq 1
        expect(Ks::SERVERS).to include(cpu.server)

        expect(Ks::Journal.count).to eq 1
        expect(cpu.journal.class).to eq Ks::Journal
        expect(cpu.journal.cpus.size).to eq 1
        expect(cpu.journal.cpus_count).to eq 1
        expect(cpu.journal.cpus.first.id).to eq cpu.id
      end

      it "destroy journal" do
        journal = cpu.journal
        journal.destroy # destroy! would also work but delete would not because it would not destroy the cpu

        expect(Ks::Journal.count).to eq 0
        expect(Ks::Cpu.count).to eq 0
      end

      it "delete cpu from collection" do
        journal = cpu.journal
        expect(journal.cpus.size).to eq 1
        expect(journal.cpus_count).to eq 1

        journal.cpus.delete(cpu) # destroy would also work as it alsways destroys dependents irrespective of dependent:

        expect(Ks::Journal.count).to eq 1
        expect(Ks::Cpu.count).to eq 0
        expect(journal.cpus.size).to eq 0
        expect(journal.cpus_count).to eq 0
      end
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
