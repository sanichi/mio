require 'rails_helper'

describe Ks::Pcpu do
  context "creation" do
    let!(:pcpu1) { create(:ks_pcpu) }
    let!(:pcpu2) { create(:ks_pcpu, cpu: pcpu1.cpu) }
    let!(:pcpu3) { create(:ks_pcpu, cpu: pcpu1.cpu) }
    let!(:pcpu4) { create(:ks_pcpu, cpu: pcpu1.cpu) }

    context "success" do
      it "creation" do
        expect(Ks::Cpu.count).to eq 1
        expect(Ks::Pcpu.count).to eq 4

        cpu = pcpu1.cpu
        expect(pcpu2.cpu).to eq cpu
        expect(pcpu3.cpu).to eq cpu
        expect(pcpu4.cpu).to eq cpu
        expect(cpu.pcpus.size).to eq 4
        expect(cpu.pcpus_count).to eq 4
        expect(cpu.journal.pcpus_count).to eq 0 # not a cache counter, only maintained in Ks.import

        cpu.journal.destroy!
        expect(Ks::Journal.count).to eq 0
        expect(Ks::Cpu.count).to eq 0
        expect(Ks::Pcpu.count).to eq 0
      end

      it "accepts a zero pcpu" do
        pcpu = create(:ks_pcpu, pcpu: "0.0")
        expect(pcpu.pcpu).to eq 0.0
      end

      it "corrects a high pcpu" do
        pcpu = create(:ks_pcpu, pcpu: "10000")
        expect(pcpu.pcpu).to eq Ks::Pcpu::MAX_PCPU
      end
    end

    context "failure" do
      it "bad command" do
        expect{create(:ks_pcpu, command: "")}.to raise_error(/Command can't be blank/)
      end

      it "bad pcpu" do
        expect{create(:ks_pcpu, pcpu: -0.1)}.to raise_error(/Pcpu must be greater than or equal to 0/)
      end

      it "no cpu" do
        expect{create(:ks_pcpu, cpu: nil)}.to raise_error(/PG::NotNullViolation/)
      end
    end
  end
end
