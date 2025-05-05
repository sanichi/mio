require 'rails_helper'

describe Ks::Proc do
  context "creation" do
    let!(:proc1) { create(:ks_proc) }
    let!(:proc2) { create(:ks_proc, top: proc1.top) }
    let!(:proc3) { create(:ks_proc, top: proc1.top) }
    let!(:proc4) { create(:ks_proc, top: proc1.top) }

    it "success" do
      expect(Ks::Top.count).to eq 1
      expect(Ks::Proc.count).to eq 4

      top = proc1.top
      expect(top).to eq proc2.top
      expect(top).to eq proc3.top
      expect(top).to eq proc4.top
      expect(top.procs.size).to eq 4
      expect(top.procs_count).to eq 4
      expect(top.procs[0].mem).to be >= top.procs[1].mem
      expect(top.procs[1].mem).to be >= top.procs[2].mem
      expect(top.procs[2].mem).to be >= top.procs[3].mem

      top.journal.destroy!
      expect(Ks::Journal.count).to eq 0
      expect(Ks::Top.count).to eq 0
      expect(Ks::Proc.count).to eq 0
    end

    context "failure" do
      it "bad command" do
        expect{create(:ks_proc, command: "")}.to raise_error(/Command can't be blank/)
      end

      it "bad mem" do
        expect{create(:ks_proc, mem: -1)}.to raise_error(/Mem must be greater than or equal to 0/)
      end

      it "no top" do
        expect{create(:ks_proc, top: nil)}.to raise_error(/PG::NotNullViolation/)
      end
    end
  end
end
