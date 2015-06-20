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
    let!(:malc)    { create(:person, born: 1957, male: true, father: john, mother: pat) }
    let!(:kirk)    { create(:person, born: 1967, male: true, mother: june) }
    let!(:paula)   { create(:person, born: 1967, male: false, father: doug) }
    let!(:penny)   { create(:person, born: 1986, male: false, father: mark) }
    let!(:faye)    { create(:person, born: 1986, male: false, father: malc) }
    let!(:jamie)   { create(:person, born: 1986, male: true, father: kirk) }

    it "self" do
      expect(thomas.relationship(thomas).to_s).to eq "identity"
      expect(june.relationship(june).to_s).to eq "identity"
    end

    it "father/son/mother/daughter" do
      expect(doug.relationship(thomas).to_s).to eq "father"
      expect(thomas.relationship(tom).to_s).to eq "son"
      expect(pat.relationship(mona).to_s).to eq "mother"
      expect(mona.relationship(pat).to_s).to eq "daughter"
    end

    it "brother/sister" do
      expect(joe.relationship(john).to_s).to eq "brother"
      expect(john.relationship(joe).to_s).to eq "brother"
      expect(beth.relationship(jean).to_s).to eq "sister"
      expect(jean.relationship(beth).to_s).to eq "sister"
      expect(tom.relationship(pat).to_s).to eq "sister"
      expect(pat.relationship(tom).to_s).to eq "brother"
    end

    it "grandfather/grandson/grandmother/granddaughter" do
      expect(mark.relationship(thomas).to_s).to eq "grandfather"
      expect(thomas.relationship(mark).to_s).to eq "grandson"
      expect(kirk.relationship(mona).to_s).to eq "grandmother"
      expect(mona.relationship(kirk).to_s).to eq "grandson"
      expect(paula.relationship(mona).to_s).to eq "grandmother"
      expect(mona.relationship(paula).to_s).to eq "granddaughter"
      expect(penny.relationship(thomas).to_s).to eq "great-grandfather"
      expect(mona.relationship(jamie).to_s).to eq "great-grandson"
      expect(jamie.relationship(mona).to_s).to eq "great-grandmother"
      expect(thomas.relationship(penny).to_s).to eq "great-granddaughter"
    end

    it "uncle/aunt/nephew/niece" do
      expect(kirk.relationship(tom).to_s).to eq "uncle"
      expect(tom.relationship(kirk).to_s).to eq "nephew"
      expect(malc.relationship(beth).to_s).to eq "aunt"
      expect(beth.relationship(malc).to_s).to eq "nephew"
      expect(mark.relationship(faye).to_s).to eq "niece"
      expect(jamie.relationship(doug).to_s).to eq "great-uncle"
      expect(doug.relationship(jamie).to_s).to eq "great-nephew"
      expect(penny.relationship(june).to_s).to eq "great-aunt"
      expect(june.relationship(penny).to_s).to eq "great-niece"
    end

    it "cousin" do
      expect(mark.relationship(kirk).to_s).to eq "1st cousin"
      expect(kirk.relationship(mark).to_s).to eq "1st cousin"
      expect(penny.relationship(faye).to_s).to eq "1st cousin"
      expect(faye.relationship(penny).to_s).to eq "1st cousin"
      expect(malc.relationship(jamie).to_s).to eq "1st cousin once removed"
      expect(jamie.relationship(malc).to_s).to eq "1st cousin once removed"
      expect(penny.relationship(kirk).to_s).to eq "1st cousin once removed"
      expect(kirk.relationship(penny).to_s).to eq "1st cousin once removed"
      expect(penny.relationship(jamie).to_s).to eq "2nd cousin"
      expect(jamie.relationship(penny).to_s).to eq "2nd cousin"
    end
  end
end
