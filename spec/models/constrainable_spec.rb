require 'rails_helper'

describe Constrainable do
  context Fund do    
    it "responds to method" do
      expect(Fund.respond_to?(:constraint)).to be true
    end
    
    it "blank and errors" do
      expect(Fund.constraint(nil, :x)).to be nil
      expect(Fund.constraint("", :x)).to be nil
      expect(Fund.constraint(" ", :x)).to be nil
    end

    it "ranges" do
      expect(Fund.constraint("1 7", :srri)).to eq "srri >= 1 AND srri <= 7"
      expect(Fund.constraint("1.1 6.9", :srri)).to eq "srri >= 1 AND srri <= 7"
      expect(Fund.constraint("0.0 1.0", :fee)).to eq "fee >= 0 AND fee <= 1"
      expect(Fund.constraint("0.5 1.2", :fee, digits: 1)).to eq "fee >= 0.5 AND fee <= 1.2"
      expect(Fund.constraint("0.5 1.2", :fee, digits: 2)).to eq "fee >= 0.50 AND fee <= 1.20"
    end

    it "inequalities" do
      expect(Fund.constraint(">1", :srri)).to eq "srri > 1"
      expect(Fund.constraint(">= 2", :srri, digits: 1)).to eq "srri >= 2.0"
      expect(Fund.constraint("< 1.061", :fee, digits: 2)).to eq "fee < 1.06"
      expect(Fund.constraint(" <=  0.45 ", :fee, digits: 3)).to eq "fee <= 0.450"
    end

    it "equalities" do
      expect(Fund.constraint("1", :srri)).to eq "srri = 1"
      expect(Fund.constraint("2", :srri, digits: 1)).to eq "srri = 2.0"
      expect(Fund.constraint("1.061", :fee, digits: 2)).to eq "fee = 1.06"
      expect(Fund.constraint("  0.45 ", :fee, digits: 3)).to eq "fee = 0.450"
    end
  end
end
