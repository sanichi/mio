require 'rails_helper'

describe Classifier do
  context "success" do
    it "normalisation" do
      c = Classifier.create!(
        category: " POS| D/D | s/o ",
        color: " FF 00 FF",
        description: "\n MARKS & SPARKS \n \n\n  TESCOS \n\t\nMORRISONS\t ",
        max_amount: "",
        min_amount: "-75",
        name: " Test   One\t ",
      )
      expect(c.category).to eq "D/D|POS|S/O"
      expect(c.color).to eq "ff00ff"
      expect(c.description).to eq "MARKS & SPARKS\nMORRISONS\nTESCOS"
      expect(c.max_amount).to eq 0.0
      expect(c.min_amount).to eq -75.0
      expect(c.name).to eq "Test One"

      expect(c.cre).to match "D/D"
      expect(c.cre).to match "POS"
      expect(c.cre).to match "S/O"
      expect(c.dre).to match "MARKS & SPARKS"
      expect(c.dre).to match "MORRISONS"
      expect(c.dre).to match "TESCOS"
    end
  end

  context "failure" do
    context "verification" do
      it "category" do
        expect{create(:classifier, category: nil)}.to raise_error(/Category can't be blank/)
        expect{create(:classifier, category: "C[")}.to raise_error(/Category invalid regexp/)
      end

      it "color" do
        expect{create(:classifier, color: nil)}.to raise_error(/Color can't be blank/)
        expect{create(:classifier, color: "gg00gg")}.to raise_error(/Color is invalid/)
      end

      it "description" do
        expect{create(:classifier, description: nil)}.to raise_error(/Description can't be blank/)
        expect{create(:classifier, description: "D[")}.to raise_error(/Description invalid regexp/)
      end

      it "max_amount" do
        expect{create(:classifier, max_amount: "nan")}.to raise_error(/Max amount is not a number/)
        expect{create(:classifier, max_amount: 1 + Transaction::MAX_AMOUNT)}.to raise_error(/Max amount must be less than or equal to 1000000.0/)
        expect{create(:classifier, max_amount: -1 - Transaction::MAX_AMOUNT)}.to raise_error(/Max amount must be greater than or equal to -1000000.0/)
      end

      it "min_amount" do
        expect{create(:classifier, min_amount: "nan")}.to raise_error(/Min amount is not a number/)
        expect{create(:classifier, min_amount: 1 + Transaction::MAX_AMOUNT)}.to raise_error(/Min amount must be less than or equal to 1000000.0/)
        expect{create(:classifier, min_amount: -1 - Transaction::MAX_AMOUNT)}.to raise_error(/Min amount must be greater than or equal to -1000000.0/)
      end

      it "amounts" do
        expect{create(:classifier, max_amount: 0, min_amount: 10)}.to raise_error(/Max amount less than Min amount/)
        expect{create(:classifier, max_amount: 0, min_amount: 0)}.to raise_error(/Max amount and Min amount both zero/)
        expect{create(:classifier, max_amount: 10, min_amount: 10)}.not_to raise_error
      end

      it "name" do
        expect{create(:classifier, name: nil)}.to raise_error(/Name can't be blank/)
        expect{create(:classifier, name: "N" * (Classifier::MAX_NAME + 1))}.to raise_error(/Name is too long/)
        expect{create(:classifier, name: "X")}.not_to raise_error
        expect{create(:classifier, name: "X")}.to raise_error(/Name has already been taken/)
      end
    end
  end

  context "transactions" do
    let(:coffee) { create(:transaction, amount: -10.0, category: "POS", description: "ARTISAN") }

    it "success" do
      expect(coffee).to be_match(create(:classifier, category: "POS|S/O", max_amount: "0", min_amount: "-20", description: "ARTISAN\nJOHN LEWIS"))
    end

    it "category" do
      expect(coffee).to_not be_match(create(:classifier, category: "D/D|S/O", max_amount: "0", min_amount: "-20", description: "ARTISAN|CALUMS"))
    end

    it "max_amount" do
      expect(coffee).to_not be_match(create(:classifier, category: "TRN|POS", max_amount: "-15", min_amount: "-20", description: "ARTISAN\nINSTA"))
    end

    it "min_amount" do
      expect(coffee).to_not be_match(create(:classifier, category: "D/D|POS", max_amount: "0", min_amount: "-5", description: "ARTISAN|JOHN LEWIS"))
    end

    it "description" do
      expect(coffee).to_not be_match(create(:classifier, category: "POS", max_amount: "0", min_amount: "-20", description: "QUIPI|COSTA"))
    end
  end
end
