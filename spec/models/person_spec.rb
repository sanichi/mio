require 'rails_helper'

describe Person do
  context "#name" do
    let(:mum) { create(:person, first_names: "Ruth Patricia Legard", known_as: "Pat", last_name: "Algeo", born: 1927, married_name: "Orr", male: false) }
    let(:dad) { create(:person, first_names: "John", known_as: "John", last_name: "Orr", born: 1931, died: 2015, male: true) }

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

    it "normal, full, with known as, with years" do
      expect(mum.name(reversed: false, full: true, with_known_as: true, with_years: true)).to eq "Ruth Patricia Legard (Pat) Algeo 1927"
      expect(dad.name(reversed: false, full: true, with_known_as: true, with_years: true)).to eq "John Orr 1931-2015"
    end

    it "normal, full, with known as, with married name" do
      expect(mum.name(reversed: false, full: true, with_known_as: true, with_married_name: true)).to eq "Ruth Patricia Legard (Pat) Algeo (Orr)"
      expect(dad.name(reversed: false, full: true, with_known_as: true, with_married_name: true)).to eq "John Orr"
    end
  end

  context "#relationship" do
    let!(:thomas)  { create(:person, born: 1900, male: true, first_names: "Thomas") }
    let!(:mona)    { create(:person, born: 1901, male: false, first_names: "Mona") }
    let!(:pat)     { create(:person, born: 1927, male: false, father: thomas, mother: mona, first_names: "Pat") }
    let!(:tom)     { create(:person, born: 1935, male: true, father: thomas, mother: mona, first_names: "Tom") }
    let!(:june)    { create(:person, born: 1937, male: false, father: thomas, mother: mona, first_names: "June") }
    let!(:doug)    { create(:person, born: 1939, male: true, father: thomas, mother: mona, first_names: "Doug") }
    let!(:gerry)   { create(:person, born: 1936, male: true, first_names: "Gerry") }
    let!(:william) { create(:person, born: 1885, male: true, first_names: "William") }
    let!(:marlene) { create(:person, born: 1907, male: false, first_names: "Marlene") }
    let!(:john)    { create(:person, born: 1930, male: true, father: william, mother: marlene, first_names: "John") }
    let!(:joe)     { create(:person, born: 1940, male: true, father: william, mother: marlene, first_names: "Joe") }
    let!(:lily)    { create(:person, born: 1935, male: false, first_names: "Lily") }
    let!(:beth)    { create(:person, born: 1935, male: false, father: william, mother: marlene, first_names: "Beth") }
    let!(:jean)    { create(:person, born: 1929, male: false, father: william, mother: marlene, first_names: "Jean") }
    let!(:mark)    { create(:person, born: 1955, male: true, father: john, mother: pat, first_names: "Mark") }
    let!(:sandra)  { create(:person, born: 1957, male: false, first_names: "Sandra") }
    let!(:malc)    { create(:person, born: 1957, male: true, father: john, mother: pat, first_names: "Malc") }
    let!(:al)      { create(:person, born: 1960, male: false, first_names: "Al") }
    let!(:ross)    { create(:person, born: 1990, male: true, mother: al, first_names: "Ross") }
    let!(:kirk)    { create(:person, born: 1967, male: true, father: gerry, mother: june, first_names: "Kirk") }
    let!(:paula)   { create(:person, born: 1967, male: false, father: doug, first_names: "Paula") }
    let!(:penny)   { create(:person, born: 1986, male: false, father: mark, first_names: "Penny") }
    let!(:faye)    { create(:person, born: 1986, male: false, father: malc, first_names: "Faye") }
    let!(:tracey)  { create(:person, born: 1980, male: false, father: malc, first_names: "Tracey") }
    let!(:jamie)   { create(:person, born: 1986, male: true, father: kirk, first_names: "Jamie") }
    let!(:ge_ju)   { create(:partnership, wedding: 1960, marriage: true, husband: gerry, wife: june) }
    let!(:jo_li)   { create(:partnership, wedding: 1950, marriage: true, husband: joe, wife: lily) }
    let!(:jo_pa)   { create(:partnership, wedding: 1950, marriage: true, husband: john, wife: pat) }
    let!(:ma_al)   { create(:partnership, wedding: 1990, marriage: true, husband: malc, wife: al) }
    let!(:ma_sa)   { create(:partnership, wedding: 1994, marriage: true, husband: mark, wife: sandra) }
    let!(:th_mo)   { create(:partnership, wedding: 1925, marriage: true, husband: thomas, wife: mona) }
    let!(:wm_ma)   { create(:partnership, wedding: 1927, marriage: true, husband: william, wife: marlene) }

    it "self" do
      expect(thomas.relationship(thomas).to_s).to eq "self"
      expect(june.relationship(june).to_s).to eq "self"
    end

    it "father/son/mother/daughter" do
      expect(thomas.relationship(tom).to_s).to eq "father"
      expect(doug.relationship(thomas).to_s).to eq "son"
      expect(mona.relationship(pat).to_s).to eq "mother"
      expect(pat.relationship(mona).to_s).to eq "daughter"
    end

    it "brother/sister" do
      expect(joe.relationship(john).to_s).to eq "brother"
      expect(john.relationship(joe).to_s).to eq "brother"
      expect(beth.relationship(jean).to_s).to eq "sister"
      expect(jean.relationship(beth).to_s).to eq "sister"
      expect(tom.relationship(pat).to_s).to eq "brother"
      expect(pat.relationship(tom).to_s).to eq "sister"
    end

    it "grandfather/grandson/grandmother/granddaughter" do
      expect(thomas.relationship(mark).to_s).to eq "grandfather"
      expect(kirk.relationship(mona).to_s).to eq "grandson"
      expect(mona.relationship(kirk).to_s).to eq "grandmother"
      expect(paula.relationship(mona).to_s).to eq "granddaughter"
      expect(penny.relationship(thomas).to_s).to eq "great-granddaughter"
      expect(mona.relationship(jamie).to_s).to eq "great-grandmother"
      expect(jamie.relationship(mona).to_s).to eq "great-grandson"
      expect(thomas.relationship(penny).to_s).to eq "great-grandfather"
    end

    it "uncle/aunt/nephew/niece" do
      expect(tom.relationship(kirk).to_s).to eq "uncle"
      expect(beth.relationship(malc).to_s).to eq "aunt"
      expect(malc.relationship(beth).to_s).to eq "nephew"
      expect(faye.relationship(mark).to_s).to eq "niece"
      expect(jamie.relationship(doug).to_s).to eq "great-nephew"
      expect(doug.relationship(jamie).to_s).to eq "great-uncle"
      expect(penny.relationship(june).to_s).to eq "great-niece"
      expect(june.relationship(penny).to_s).to eq "great-aunt"
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

    it "husband/wife" do
      expect(thomas.relationship(mona).to_s).to eq "husband"
      expect(mona.relationship(thomas).to_s).to eq "wife"
      expect(mark.relationship(sandra).to_s).to eq "husband"
      expect(sandra.relationship(mark).to_s).to eq "wife"
    end

    it "father/son/mother/daughter by marriage" do
      expect(john.relationship(sandra).to_s).to eq "father-in-law"
      expect(marlene.relationship(pat).to_s).to eq "mother-in-law"
      expect(john.relationship(mona).to_s).to eq "son-in-law"
      expect(al.relationship(pat).to_s).to eq "daughter-in-law"
    end

    it "step father/son/mother/daughter" do
      expect(malc.relationship(ross).to_s).to eq "step-father"
      expect(ross.relationship(malc).to_s).to eq "step-son"
      expect(sandra.relationship(penny).to_s).to eq "step-mother"
      expect(penny.relationship(sandra).to_s).to  eq "step-daughter"
    end

    it "step brother/sister" do
      expect(ross.relationship(tracey).to_s).to eq "step-brother"
      expect(faye.relationship(ross).to_s).to eq "step-sister"
    end

    it "brother/sister by marriage" do
      expect(malc.relationship(sandra).to_s).to eq "brother-in-law"
      expect(john.relationship(gerry).to_s).to eq "brother-in-law"
      expect(pat.relationship(lily).to_s).to eq "sister-in-law"
      expect(lily.relationship(beth).to_s).to eq "sister-in-law"
    end

    it "uncle/aunt/nephew/niece by marriage" do
      expect(gerry.relationship(mark).to_s).to eq "uncle"
      expect(malc.relationship(gerry).to_s).to eq "nephew"
      expect(lily.relationship(mark).to_s).to eq "aunt"
      expect(faye.relationship(sandra).to_s).to eq "niece"
    end

    it "no relation" do
      expect(thomas.relationship(william).to_s).to eq "no relation"
      expect(mona.relationship(marlene).to_s).to eq "no relation"
    end

    it "capitalization" do
      expect(thomas.relationship(mark).to_s(caps: true)).to eq "Grandfather"
      expect(mona.relationship(jamie).to_s(caps: true)).to eq "Great-Grandmother"
      expect(thomas.relationship(william).to_s(caps: true)).to eq "No Relation"
      expect(john.relationship(gerry).to_s(caps: true)).to eq "Brother-in-Law"
      expect(malc.relationship(ross).to_s(caps: true)).to eq "Step-Father"
      expect(malc.relationship(jamie).to_s(caps: true)).to eq "1st Cousin once removed"
    end
  end

  context "#partners" do
    let!(:mark)      { create(:person, born: 1955, male: true) }
    let!(:lynda)     { create(:person, born: 1967, male: false) }
    let!(:aphrodite) { create(:person, born: 1969, male: false) }
    let!(:pat)       { create(:person, born: 1942, male: false) }
    let!(:m_a)       { create(:partnership, husband: mark, wedding: 1988, marriage: false, wife: aphrodite) }
    let!(:m_p)       { create(:partnership, husband: mark, wedding: 1989, marriage: false, wife: pat) }
    let!(:m_l)       { create(:partnership, husband: mark, wedding: 1990, marriage: false, wife: lynda) }

    it "order by partnership start, not partner age" do
      expect(mark.partners.map(&:id)).to eq [aphrodite.id, pat.id, lynda.id]
    end
  end
end
