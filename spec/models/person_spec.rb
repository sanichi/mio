require 'rails_helper'

describe Person do
  context "#name" do
    let(:mum) { create(:person, first_names: "Ruth Patricia Legard", known_as: "Pat", last_name: "Algeo") }
    let(:dad) { create(:person, first_names: "John", known_as: "John", last_name: "Orr") }

    it "default" do
      expect(mum.name).to eq "Ruth Patricia Legard (Pat) Algeo"
      expect(dad.name).to eq "John Orr"
    end

    it "normal, full, without known as" do
      expect(mum.name(reversed: false, full: true, with_known_as: false)).to eq "Ruth Patricia Legard Algeo"
      expect(dad.name(reversed: false, full: true, with_known_as: false)).to eq "John Orr"
    end

    it "normal, short, without known as" do
      expect(mum.name(reversed: false, full: false, with_known_as: false)).to eq "Pat Algeo"
      expect(dad.name(reversed: false, full: false, with_known_as: false)).to eq "John Orr"
    end

    it "reversed, full, without known as" do
      expect(mum.name(reversed: true, full: true, with_known_as: false)).to eq "Algeo, Ruth Patricia Legard"
      expect(dad.name(reversed: true, full: true, with_known_as: false)).to eq "Orr, John"
    end

    it "reversed, short, without known as" do
      expect(mum.name(reversed: true, full: false, with_known_as: false)).to eq "Algeo, Pat"
      expect(dad.name(reversed: true, full: false, with_known_as: false)).to eq "Orr, John"
    end

    it "normal, full, with known as" do
      expect(mum.name(reversed: false, full: true, with_known_as: true)).to eq "Ruth Patricia Legard (Pat) Algeo"
      expect(dad.name(reversed: false, full: true, with_known_as: true)).to eq "John Orr"
    end

    it "normal, short, with known as" do
      expect(mum.name(reversed: false, full: false, with_known_as: true)).to eq "Pat Algeo"
      expect(dad.name(reversed: false, full: false, with_known_as: true)).to eq "John Orr"
    end

    it "reversed, full, with known as" do
      expect(mum.name(reversed: true, full: true, with_known_as: true)).to eq "Algeo, Ruth Patricia Legard (Pat)"
      expect(dad.name(reversed: true, full: true, with_known_as: true)).to eq "Orr, John"
    end

    it "reversed, short, with known as" do
      expect(mum.name(reversed: true, full: false, with_known_as: true)).to eq "Algeo, Pat"
      expect(dad.name(reversed: true, full: false, with_known_as: true)).to eq "Orr, John"
    end
  end

  context "#relationship" do
    let!(:thomas)  { create(:person, born: 1900, male: true) }
    let!(:mona)    { create(:person, born: 1901, male: false) }
    let!(:pat)     { create(:person, born: 1927, male: false, father: thomas, mother: mona) }
    let!(:tom)     { create(:person, born: 1935, male: true, father: thomas, mother: mona) }
    let!(:june)    { create(:person, born: 1937, male: false, father: thomas, mother: mona) }
    let!(:doug)    { create(:person, born: 1939, male: true, father: thomas, mother: mona) }
    let!(:william) { create(:person, born: 1885, male: true) }
    let!(:marlene) { create(:person, born: 1907, male: false) }
    let!(:john)    { create(:person, born: 1930, male: true, father: william, mother: marlene) }
    let!(:joe)     { create(:person, born: 1940, male: true, father: william, mother: marlene) }
    let!(:beth)    { create(:person, born: 1935, male: false, father: william, mother: marlene) }
    let!(:jean)    { create(:person, born: 1929, male: false, father: william, mother: marlene) }
    let!(:mark)    { create(:person, born: 1955, male: true, father: john, mother: pat) }

    it "self" do
      expect(thomas.relationship(thomas)).to eq :self
      expect(june.relationship(june)).to eq :self
    end
  end
end
