require 'rails_helper'

describe Constrainable do
  context "#numerical_constraint" do
    it "responds to method" do
      expect(Favourite.respond_to?(:numerical_constraint)).to be true
    end

    it "blank and errors" do
      expect(Favourite.numerical_constraint(nil, :x)).to be nil
      expect(Favourite.numerical_constraint("", :x)).to be nil
      expect(Favourite.numerical_constraint(" ", :x)).to be nil
    end

    it "ranges" do
      expect(Favourite.numerical_constraint("1 7", :srri)).to eq "srri >= 1 AND srri <= 7"
      expect(Favourite.numerical_constraint("1.1 6.9", :srri)).to eq "srri >= 1 AND srri <= 7"
      expect(Favourite.numerical_constraint("0.0 1.0", :fee)).to eq "fee >= 0 AND fee <= 1"
      expect(Favourite.numerical_constraint("0.5 1.2", :fee, digits: 1)).to eq "fee >= 0.5 AND fee <= 1.2"
      expect(Favourite.numerical_constraint("0.5 1.2", :fee, digits: 2)).to eq "fee >= 0.50 AND fee <= 1.20"
      expect(Favourite.numerical_constraint("-1.2 -0.3", :fee, digits: 1)).to eq "fee >= -1.2 AND fee <= -0.3"
    end

    it "inequalities" do
      expect(Favourite.numerical_constraint(">1", :srri)).to eq "srri > 1"
      expect(Favourite.numerical_constraint(">= 2", :srri, digits: 1)).to eq "srri >= 2.0"
      expect(Favourite.numerical_constraint("< 1.061", :fee, digits: 2)).to eq "fee < 1.06"
      expect(Favourite.numerical_constraint(" <=  0.45 ", :fee, digits: 3)).to eq "fee <= 0.450"
      expect(Favourite.numerical_constraint(">-7", :fee, digits: 0)).to eq "fee > -7"
    end

    it "equalities" do
      expect(Favourite.numerical_constraint("1", :srri)).to eq "srri = 1"
      expect(Favourite.numerical_constraint("2", :srri, digits: 1)).to eq "srri = 2.0"
      expect(Favourite.numerical_constraint("1.061", :fee, digits: 2)).to eq "fee = 1.06"
      expect(Favourite.numerical_constraint("  0.45 ", :fee, digits: 3)).to eq "fee = 0.450"
      expect(Favourite.numerical_constraint("=3", :fee)).to eq "fee = 3"
      expect(Favourite.numerical_constraint(" = 7.2 ", :fee, digits: 3)).to eq "fee = 7.200"
      expect(Favourite.numerical_constraint(" =  -34.567 ", :fee, digits: 2)).to eq "fee = -34.57"
    end
  end

  context "cross_constraint" do
    it "responds to method" do
      expect(Person.respond_to?(:cross_constraint)).to be true
    end

    it "no terms" do
      expect(Person.cross_constraint(nil, %w(c))).to be_nil
      expect(Person.cross_constraint("", %w(c))).to be_nil
      expect(Person.cross_constraint("£' &%", %w(c))).to be_nil
    end

    it "one term" do
      expect(Person.cross_constraint("ma", %w(c1 c2))).to eq "c1 ILIKE '%ma%' OR c2 ILIKE '%ma%'"
      expect(Person.cross_constraint("ah-ja", %w(c))).to eq "c ILIKE '%ah-ja%'"
    end

    it "two terms" do
      expect(Person.cross_constraint(" x  y ", %w(c1 c2))).to eq "(c1 ILIKE '%x%' OR c2 ILIKE '%x%') AND (c1 ILIKE '%y%' OR c2 ILIKE '%y%')"
    end

    it "with table name" do
      expect(Person.cross_constraint("a", %w(c), table: "people")).to eq "people.c ILIKE '%a%'"
    end

    it "regular expression" do
      expect(Person.cross_constraint("/^Mark$/", %w(c))).to eq "c ~* '^Mark$'"
      expect(Person.cross_constraint("/^Mark$/", %w(c1 c2))).to eq "c1 ~* '^Mark$' OR c2 ~* '^Mark$'"
      expect(Person.cross_constraint("/^Mark$/", %w(c1 c2), table: "person")).to eq "person.c1 ~* '^Mark$' OR person.c2 ~* '^Mark$'"
      expect(Person.cross_constraint("/^Mark$", %w(c1 c2), table: "person")).to eq "person.c1 ~* '^Mark$' OR person.c2 ~* '^Mark$'"
    end
  end
end
