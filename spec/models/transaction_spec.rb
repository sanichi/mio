require 'rails_helper'

describe Transaction do
  context "classifiers" do
    let!(:coffee)    { create(:classifier, min_amount: -5.0, category: "POS|D/D", description: "ARTISAN|COSTA") }
    let!(:groceries) { create(:classifier, min_amount: -100.0, category: "POS", description: "LIDDLE\nASDA") }
    let!(:pension)   { create(:classifier, min_amount: 250, max_amount: 350, category: "BAC|DPC", description: "USS\nHL")}

    it "create transactions and destroy classifier" do
      expect(create(:transaction, amount: "-2.50", category: "POS", description: "ARTISAN").classifier).to eq coffee
      expect(create(:transaction, amount: "-3.30", category: "D/D", description: "COSTA").classifier).to eq coffee
      expect(create(:transaction, amount: "-50.93", category: "POS", description: "ASDA").classifier).to eq groceries
      expect(create(:transaction, amount: "284.32", category: "BAC", description: "USS").classifier).to eq pension
      expect(create(:transaction, amount: "705.01", category: "BAC", description: "PENSION").classifier).to be_nil

      expect(Transaction.where(classifier: coffee).count).to eq 2
      expect(Transaction.where(classifier: groceries).count).to eq 1
      expect(Transaction.where(classifier: pension).count).to eq 1
      expect(Transaction.where(classifier: nil).count).to eq 1

      coffee.destroy

      expect(Transaction.where(classifier: groceries).count).to eq 1
      expect(Transaction.where(classifier: pension).count).to eq 1
      expect(Transaction.where(classifier: nil).count).to eq 3
    end

    it "create transactions and alter classifier" do
      expect(create(:transaction, amount: "-2.50", category: "POS", description: "ARTISAN").classifier).to eq coffee
      expect(create(:transaction, amount: "-3.30", category: "D/D", description: "COSTA").classifier).to eq coffee
      expect(create(:transaction, amount: "-9.90", category: "POS", description: "COSTA").classifier).to eq nil
      expect(create(:transaction, amount: "-4.80", category: "POS", description: "STARBUCKS").classifier).to eq nil
      expect(create(:transaction, amount: "-1.30", category: "S/O", description: "STARBUCKS").classifier).to eq nil

      expect(Transaction.where(classifier: coffee).count).to eq 2
      expect(Transaction.where(classifier: nil).count).to eq 3

      coffee.min_amount = -20.0
      coffee.save

      expect(Transaction.where(classifier: coffee).count).to eq 3
      expect(Transaction.where(classifier: nil).count).to eq 2

      coffee.description = "ARTISAN|COSTA|STARBUCKS"
      coffee.save

      expect(Transaction.where(classifier: coffee).count).to eq 4
      expect(Transaction.where(classifier: nil).count).to eq 1

      coffee.category = "POS|D/D|S/O"
      coffee.save

      expect(Transaction.where(classifier: coffee).count).to eq 5
      expect(Transaction.where(classifier: nil).count).to eq 0

      coffee.max_amount = "-4"
      coffee.save

      expect(Transaction.where(classifier: coffee).count).to eq 2
      expect(Transaction.where(classifier: nil).count).to eq 3

      coffee.max_amount = coffee.min_amount
      coffee.save

      expect(Transaction.where(classifier: coffee).count).to eq 0
      expect(Transaction.where(classifier: nil).count).to eq 5
    end

    it "create transactions and create classifier" do
      expect(create(:transaction, amount: "-4.50", category: "POS", description: "ARTISAN").classifier).to eq coffee
      expect(create(:transaction, amount: "100.0", category: "DPC", description: "To A/C 00101456").classifier).to eq nil
      expect(create(:transaction, amount: "-100.0", category: "DPC", description: "From A/C 00123450").classifier).to eq nil

      expect(Transaction.where(classifier: coffee).count).to eq 1
      expect(Transaction.where(classifier: nil).count).to eq 2

      transfer = create(:classifier, min_amount: -1000, max_amount: 1000, category: "DPC", description: "(FROM|TO) A/C (00101456|00123450)")

      expect(Transaction.where(classifier: transfer).count).to eq 2
      expect(Transaction.where(classifier: coffee).count).to eq 1
      expect(Transaction.where(classifier: nil).count).to eq 0
    end
  end
end
