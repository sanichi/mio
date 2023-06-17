require 'rails_helper'

describe Classifier do
  def dummy(category: "C", color: "ff00ff", description: "D", max_amount: "0", min_amount: "0", name: "N")
    Classifier.create!(category: category, color: color, description: description, max_amount: max_amount, min_amount: min_amount, name: name)
  end

  context "success" do
    it "normalisation" do
      c = Classifier.create!(
        category: " POS| D/D | S/ O ",
        color: " FF 00 FF",
        description: "\n MARKS & SPARKS \n \n\n  TESCOS \n\t\nMORRISONS\t ",
        max_amount: "0",
        min_amount: "-75",
        name: " Test   One\t ",
      )
      expect(c.category).to eq "POS|D/D|S/O"
      expect(c.color).to eq "ff00ff"
      expect(c.description).to eq "MARKS & SPARKS\nTESCOS\nMORRISONS"
      expect(c.max_amount).to eq 0.0
      expect(c.min_amount).to eq -75.0
      expect(c.name).to eq "Test One"

      expect(c.cre).to match "POS"
      expect(c.cre).to match "D/D"
      expect(c.cre).to match "S/O"
      expect(c.dre).to match "MARKS & SPARKS"
      expect(c.dre).to match "TESCOS"
      expect(c.dre).to match "MORRISONS"
    end

    it "test dummy" do
      expect{dummy()}.not_to raise_error
    end
  end

  context "failure" do
    context "verification" do
      it "category" do
        expect{dummy(category: nil)}.to raise_error(/Category can't be blank/)
        expect{dummy(category: "C[")}.to raise_error(/Category invalid regexp/)
      end

      it "color" do
        expect{dummy(color: nil)}.to raise_error(/Color can't be blank/)
        expect{dummy(color: "gg00gg")}.to raise_error(/Color is invalid/)
      end

      it "description" do
        expect{dummy(description: nil)}.to raise_error(/Description can't be blank/)
        expect{dummy(description: "D[")}.to raise_error(/Description invalid regexp/)
      end

      it "max_amount" do
        expect{dummy(max_amount: nil)}.to raise_error(/Max amount is not a number/)
        expect{dummy(max_amount: 1 + Transaction::MAX_AMOUNT)}.to raise_error(/Max amount must be less than or equal to 1000000.0/)
        expect{dummy(max_amount: -1 - Transaction::MAX_AMOUNT)}.to raise_error(/Max amount must be greater than or equal to -1000000.0/)
      end

      it "min_amount" do
        expect{dummy(min_amount: nil)}.to raise_error(/Min amount is not a number/)
        expect{dummy(min_amount: 1 + Transaction::MAX_AMOUNT)}.to raise_error(/Min amount must be less than or equal to 1000000.0/)
        expect{dummy(min_amount: -1 - Transaction::MAX_AMOUNT)}.to raise_error(/Min amount must be greater than or equal to -1000000.0/)
      end

      it "name" do
        expect{dummy(name: nil)}.to raise_error(/Name can't be blank/)
        expect{dummy(name: "N" * (Classifier::MAX_NAME + 1))}.to raise_error(/Name is too long/)
        expect{dummy()}.not_to raise_error
        expect{dummy()}.to raise_error(/Name has already been taken/)
      end
    end
  end
end
