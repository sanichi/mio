require 'rails_helper'

describe Wk::Combo do
  let!(:count)  { Hash.new(0) }
  let!(:vocab0) { create(:wk_vocab) }
  let!(:vocab1) do
    v = create(:wk_vocab)
    create(:wk_combo, vocab: v)
    v
  end
  let!(:vocab2) do
    v = create(:wk_vocab)
    create(:wk_combo, vocab: v)
    create(:wk_combo, vocab: v)
    v
  end
  let!(:vocab3) do
    v = create(:wk_vocab)
    create(:wk_combo, vocab: v)
    create(:wk_combo, vocab: v)
    create(:wk_combo, vocab: v)
    v
  end

  context "test setup" do
    it "check" do
      expect(Wk::Vocab.count).to eq 4
      expect(Wk::Combo.count).to eq 6

      expect(vocab0.combos_count).to eq 0
      expect(vocab1.combos_count).to eq 1
      expect(vocab2.combos_count).to eq 2
      expect(vocab3.combos_count).to eq 3

      expect(vocab0.combos.count).to eq 0
      expect(vocab1.combos.count).to eq 1
      expect(vocab2.combos.count).to eq 2
      expect(vocab3.combos.count).to eq 3
    end
  end

  context "merging" do
    context "no data" do
      it "0" do
        vocab0.merge([], count)
        expect(count[:additions]).to eq 0
        expect(count[:deletions]).to eq 0
        expect(count[:unchanged]).to eq 0
        expect(vocab0.combos_count).to eq 0
        expect(vocab0.combos.count).to eq 0
      end

      it "1" do
        vocab1.merge([], count)
        expect(count[:additions]).to eq 0
        expect(count[:deletions]).to eq 0
        expect(count[:unchanged]).to eq 1
        expect(vocab1.combos_count).to eq 1
        expect(vocab1.combos.count).to eq 1
      end

      it "2" do
        vocab2.merge([], count)
        expect(count[:additions]).to eq 0
        expect(count[:deletions]).to eq 0
        expect(count[:unchanged]).to eq 2
        expect(vocab2.combos_count).to eq 2
        expect(vocab2.combos.count).to eq 2
      end

      it "3" do
        vocab3.merge([], count)
        expect(count[:additions]).to eq 0
        expect(count[:deletions]).to eq 0
        expect(count[:unchanged]).to eq 3
        expect(vocab3.combos_count).to eq 3
        expect(vocab3.combos.count).to eq 3
      end
    end

    context "no combos" do
      it "1" do
        data = vocab1.combo_data
        vocab0.merge(data, count)
        expect(count[:additions]).to eq 1
        expect(count[:deletions]).to eq 0
        expect(count[:unchanged]).to eq 0
        expect(vocab0.combos_count).to eq 1
        expect(vocab0.combos.count).to eq 1
      end

      it "2" do
        data = vocab2.combo_data
        vocab0.merge(data, count)
        expect(count[:additions]).to eq 2
        expect(count[:deletions]).to eq 0
        expect(count[:unchanged]).to eq 0
        expect(vocab0.combos_count).to eq 2
        expect(vocab0.combos.count).to eq 2
      end

      it "3" do
        data = vocab3.combo_data.reverse
        vocab0.merge(data, count)
        expect(count[:additions]).to eq 3
        expect(count[:deletions]).to eq 0
        expect(count[:unchanged]).to eq 0
        expect(vocab0.combos_count).to eq 3
        expect(vocab0.combos.count).to eq 3
      end
    end

    context "same data" do
      it "1" do
        data = vocab1.combo_data
        vocab1.merge(data, count)
        expect(count[:additions]).to eq 0
        expect(count[:deletions]).to eq 0
        expect(count[:unchanged]).to eq 1
        expect(vocab1.combos_count).to eq 1
        expect(vocab1.combos.count).to eq 1
      end

      it "2" do
        data = vocab2.combo_data.reverse
        vocab2.merge(data, count)
        expect(count[:additions]).to eq 0
        expect(count[:deletions]).to eq 0
        expect(count[:unchanged]).to eq 2
        expect(vocab2.combos_count).to eq 2
        expect(vocab2.combos.count).to eq 2
      end

      it "3" do
        data = vocab3.combo_data.reverse
        vocab3.merge(data, count)
        expect(count[:additions]).to eq 0
        expect(count[:deletions]).to eq 0
        expect(count[:unchanged]).to eq 3
        expect(vocab3.combos_count).to eq 3
        expect(vocab3.combos.count).to eq 3
      end
    end

    context "new data" do
      it "0" do
        data = vocab2.combo_data
        vocab0.merge(data, count)
        expect(count[:additions]).to eq 2
        expect(count[:deletions]).to eq 0
        expect(count[:unchanged]).to eq 0
        expect(vocab0.combos_count).to eq 2
        expect(vocab0.combos.count).to eq 2
      end

      it "1" do
        data = vocab3.combo_data
        vocab1.merge(data, count)
        expect(count[:additions]).to eq 3
        expect(count[:deletions]).to eq 1
        expect(count[:unchanged]).to eq 0
        expect(vocab1.combos_count).to eq 3
        expect(vocab1.combos.count).to eq 3
      end

      it "2" do
        data = vocab1.combo_data.reverse
        vocab2.merge(data, count)
        expect(count[:additions]).to eq 1
        expect(count[:deletions]).to eq 2
        expect(count[:unchanged]).to eq 0
        expect(vocab2.combos_count).to eq 1
        expect(vocab2.combos.count).to eq 1
      end

      it "3" do
        data = vocab2.combo_data.reverse
        vocab3.merge(data, count)
        expect(count[:additions]).to eq 2
        expect(count[:deletions]).to eq 3
        expect(count[:unchanged]).to eq 0
        expect(vocab3.combos_count).to eq 2
        expect(vocab3.combos.count).to eq 2
      end
    end

    context "mixed data" do
      it "1" do
        data = vocab1.combo_data + vocab2.combo_data
        vocab1.merge(data, count)
        expect(count[:additions]).to eq 2
        expect(count[:deletions]).to eq 0
        expect(count[:unchanged]).to eq 1
        expect(vocab1.combos_count).to eq 3
        expect(vocab1.combos.count).to eq 3
      end

      it "2" do
        data = vocab2.combo_data.first(1) + vocab3.combo_data.last(2)
        vocab2.merge(data, count)
        expect(count[:additions]).to eq 2
        expect(count[:deletions]).to eq 1
        expect(count[:unchanged]).to eq 1
        expect(vocab2.combos_count).to eq 3
        expect(vocab2.combos.count).to eq 3
      end

      it "3" do
        data = vocab3.combo_data.last(2) + vocab2.combo_data
        vocab3.merge(data, count)
        expect(count[:additions]).to eq 2
        expect(count[:deletions]).to eq 1
        expect(count[:unchanged]).to eq 2
        expect(vocab3.combos_count).to eq 4
        expect(vocab3.combos.count).to eq 4
      end
    end
  end
end
