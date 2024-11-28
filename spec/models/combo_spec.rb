require 'rails_helper'

describe Wk::Combo do
  let!(:combo1a) { create(:wk_combo) }
  let!(:combo2a) { create(:wk_combo) }
  let!(:combo2b) { create(:wk_combo, vocab: combo2a.vocab) }
  let!(:combo3a) { create(:wk_combo) }
  let!(:combo3b) { create(:wk_combo, vocab: combo3a.vocab) }
  let!(:combo3c) { create(:wk_combo, vocab: combo3a.vocab) }

  context "counter_cache" do
    it "initial" do
      expect(Wk::Vocab.count).to eq 3
      expect(Wk::Combo.count).to eq 6

      expect(combo1a.vocab.combos_count).to eq 1
      expect(combo2a.vocab.combos_count).to eq 2
      expect(combo3a.vocab.combos_count).to eq 3
    end
  end
end
