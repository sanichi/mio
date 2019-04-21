require 'rails_helper'

describe ProblemQuestion do
  let(:param) { JSON.generate({ 1 => [1, 2, 3], 2 => [4, 5], 3 => [6], 4 => nil }) }

  context "build from param" do
    let(:param_json)  { "[,,}]" }
    let(:param_hash)  { JSON.generate([1, 2, 3]) }
    let(:param_array) { JSON.generate({ 1 => 1, 2 => [4, 5], 3 => [6], 4 => nil }) }
    let(:param_empty) { JSON.generate({ 1 => [], 2 => [4, 5], 3 => [6], 4 => nil }) }
    let(:param_int)   { JSON.generate({ 1 => [1, 2, "3"], 2 => [4, 5], 3 => [6], 4 => nil }) }
    let(:param_pos)   { JSON.generate({ 1 => [1, 2, 0], 2 => [4, 5], 3 => [6], 4 => nil }) }

    it "builds correctly" do
      pq = ProblemQuestion.new(param)
      expect(pq.error).to be_nil
      expect(pq.available?).to be true
      expect(pq.pids).to eq [1, 2, 3, 4]
      expect(pq.qids(1)).to eq [1, 2, 3]
      expect(pq.qids(2)).to eq [4, 5]
      expect(pq.qids(3)).to eq [6]
      expect(pq.qids(4)).to be_nil
      expect(pq.serialize).to eq param
    end

    it "detects bad JSON" do
      pq = ProblemQuestion.new(param_json)
      expect(pq.error).to match(/unexpected/)
      expect(pq.available?).to be false
      expect(pq.pids).to eq []
      expect(pq.qids(1)).to be_nil
      expect(pq.serialize).to be_nil
    end

    it "detects non hash" do
      pq = ProblemQuestion.new(param_hash)
      expect(pq.error).to match(/not a hash/)
      expect(pq.available?).to be false
    end

    it "detects non arrays" do
      pq = ProblemQuestion.new(param_array)
      expect(pq.error).to match(/not a non-empty array/)
      expect(pq.available?).to be false
    end

    it "detects empty arrays" do
      pq = ProblemQuestion.new(param_array)
      expect(pq.error).to match(/not a non-empty array/)
      expect(pq.available?).to be false
    end

    it "detects non integers" do
      pq = ProblemQuestion.new(param_int)
      expect(pq.error).to match(/not a positive integer/)
      expect(pq.available?).to be false
    end

    it "detects non positive integers" do
      pq = ProblemQuestion.new(param_pos)
      expect(pq.error).to match(/not a positive integer/)
      expect(pq.available?).to be false
    end
  end

  context "build from IDs" do
    it "builds correctly" do
      pq = ProblemQuestion.new
      expect(pq.error).to be_nil
      expect(pq.available?).to be false
      pq.add(1, 1)
      expect(pq.error).to be_nil
      expect(pq.available?).to be true
      expect(pq.pids).to eq [1]
      expect(pq.qids(1)).to eq [1]
      pq.add(1, 2)
      pq.add(1, 3)
      pq.add(2, 4)
      pq.add(2, 5)
      pq.add(3, 6)
      pq.add(4)
      expect(pq.error).to be_nil
      expect(pq.available?).to be true
      expect(pq.pids).to eq [1, 2, 3, 4]
      expect(pq.qids(1)).to eq [1, 2, 3]
      expect(pq.qids(2)).to eq [4, 5]
      expect(pq.qids(3)).to eq [6]
      expect(pq.qids(4)).to be_nil
      expect(pq.serialize).to eq param
    end
  end

  context "filtering" do
    it "filters correctly" do
      pq = ProblemQuestion.new(param)
      expect(pq.pids).to eq [1, 2, 3, 4]
      expect(pq.available?).to be true
      pq.filter([4, 2, 3, 1, 5])
      expect(pq.pids).to eq [4, 2, 3, 1]
      expect(pq.available?).to be true
      pq.filter([2, 4, 6])
      expect(pq.pids).to eq [2, 4]
      expect(pq.available?).to be true
      pq.filter([1])
      expect(pq.pids).to eq []
      expect(pq.available?).to be false
    end
  end
end
