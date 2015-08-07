require 'rails_helper'

describe Constrainable do
  context "#numerical_constraint" do
    it "responds to method" do
      expect(Fund.respond_to?(:numerical_constraint)).to be true
    end

    it "blank and errors" do
      expect(Fund.numerical_constraint(nil, :x)).to be nil
      expect(Fund.numerical_constraint("", :x)).to be nil
      expect(Fund.numerical_constraint(" ", :x)).to be nil
    end

    it "ranges" do
      expect(Fund.numerical_constraint("1 7", :srri)).to eq "srri >= 1 AND srri <= 7"
      expect(Fund.numerical_constraint("1.1 6.9", :srri)).to eq "srri >= 1 AND srri <= 7"
      expect(Fund.numerical_constraint("0.0 1.0", :fee)).to eq "fee >= 0 AND fee <= 1"
      expect(Fund.numerical_constraint("0.5 1.2", :fee, digits: 1)).to eq "fee >= 0.5 AND fee <= 1.2"
      expect(Fund.numerical_constraint("0.5 1.2", :fee, digits: 2)).to eq "fee >= 0.50 AND fee <= 1.20"
    end

    it "inequalities" do
      expect(Fund.numerical_constraint(">1", :srri)).to eq "srri > 1"
      expect(Fund.numerical_constraint(">= 2", :srri, digits: 1)).to eq "srri >= 2.0"
      expect(Fund.numerical_constraint("< 1.061", :fee, digits: 2)).to eq "fee < 1.06"
      expect(Fund.numerical_constraint(" <=  0.45 ", :fee, digits: 3)).to eq "fee <= 0.450"
    end

    it "equalities" do
      expect(Fund.numerical_constraint("1", :srri)).to eq "srri = 1"
      expect(Fund.numerical_constraint("2", :srri, digits: 1)).to eq "srri = 2.0"
      expect(Fund.numerical_constraint("1.061", :fee, digits: 2)).to eq "fee = 1.06"
      expect(Fund.numerical_constraint("  0.45 ", :fee, digits: 3)).to eq "fee = 0.450"
    end
  end

  context "name_constraint" do
    it "responds to method" do
      expect(Person.respond_to?(:name_constraint)).to be true
    end

    it "no terms" do
      expect(Person.name_constraint(nil)).to be_nil
      expect(Person.name_constraint("")).to be_nil
      expect(Person.name_constraint("12 &^%")).to be_nil
    end

    it "one terms" do
      expect(Person.name_constraint("ma")).to eq "last_name ILIKE '%ma%' OR first_names ILIKE '%ma%' OR known_as ILIKE '%ma%' OR married_name ILIKE '%ma%'"
      expect(Person.name_constraint("ah-ja")).to eq "last_name ILIKE '%ah-ja%' OR first_names ILIKE '%ah-ja%' OR known_as ILIKE '%ah-ja%' OR married_name ILIKE '%ah-ja%'"
    end

    it "two terms" do
      expect(Person.name_constraint(" x  y ")).to eq "(last_name ILIKE '%x%' OR first_names ILIKE '%x%' OR known_as ILIKE '%x%' OR married_name ILIKE '%x%') AND (last_name ILIKE '%y%' OR first_names ILIKE '%y%' OR known_as ILIKE '%y%' OR married_name ILIKE '%y%')"
    end

    it "with table name" do
      expect(Person.name_constraint("a", table: "people")).to eq "people.last_name ILIKE '%a%' OR people.first_names ILIKE '%a%' OR people.known_as ILIKE '%a%' OR people.married_name ILIKE '%a%'"
    end
  end
end
