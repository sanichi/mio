require 'rails_helper'

describe Ks::Journal do
  context "creation" do
    let(:data) { build(:ks_journal) }
    let!(:journal) { create(:ks_journal) }

    context "success" do
      it "instant creation" do
        expect(Ks::Journal.count).to eq 1
        expect(journal.created_at).to_not be_blank
      end

      it "slow buildup" do
        j = Ks::Journal.new
        j.procs_count += data.procs_count
        j.warnings += data.warnings
        j.problems += data.problems
        j.note += data.note
        expect{j.save!}.to_not raise_error
        expect(j.procs_count).to eq data.procs_count
        expect(j.warnings).to eq data.warnings
        expect(j.problems).to eq data.problems
        expect(j.note).to eq data.note
        expect(j.created_at).to_not be_blank
      end
    end

    context "failure" do
      it "bad procs_count" do
        expect{create(:ks_journal, procs_count: -1)}.to raise_error(/Procs count must be greater than or equal to 0/)
      end

      it "bad warnings" do
        expect{create(:ks_journal, warnings: -1)}.to raise_error(/Warnings must be greater than or equal to 0/)
      end

      it "bad problems" do
        expect{create(:ks_journal, problems: -1)}.to raise_error(/Problems must be greater than or equal to 0/)
      end
    end
  end
end
