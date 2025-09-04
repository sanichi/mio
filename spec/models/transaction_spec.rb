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

  context "parse transaction data" do
    context "RBS debit" do
      it "success" do
        date, category, description, amount, balance, skip = Transaction.rbs_ac(["09/06/2023","POS","5259 08JUN23 CD , FOUNTAIN CAFE , EDINBURGH GB",-10.1,"1609.25","Mark's current","831909-234510"], 1)
        expect(date.to_s).to eq "2023-06-09"
        expect(category).to eq "POS"
        expect(description).to eq "5259 08JUN23 CD , FOUNTAIN CAFE , EDINBURGH GB"
        expect(amount).to eq -10.1
        expect(balance).to eq 1609.25
        expect(skip).to be false
      end
    end

    context "RBS credit" do
      it "success" do
        date, category, description, amount, balance, skip = Transaction.rbs_cc(["20 Mar 2023","Purchase","'APPLE.COM/BILL APPLE.COM/BILIRL",10.99,'',"'M ORR","'543484******5254"],1)
        expect(date.to_s).to eq "2023-03-20"
        expect(category).to eq "PUR"
        expect(description).to eq "APPLE.COM/BILL APPLE.COM/BILIRL"
        expect(amount).to eq -10.99
        expect(balance).to eq 0.0
        expect(skip).to be false
      end
    end

    context "Starling debit" do
      it "success" do
        date, category, description, amount, balance, skip = Transaction.starling(["31/08/2025","Pret A Manger","PRET A MANGER","APPLE PAY",-2.27,285.24,"EATING_OUT"], 1)
        expect(date.to_s).to eq "2025-08-31"
        expect(category).to eq "PUR"
        expect(description).to eq "Pret A Manger"
        expect(amount).to eq -2.27
        expect(balance).to eq 285.24
        expect(skip).to be false
      end
    end
  end
end
