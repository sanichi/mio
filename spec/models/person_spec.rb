require 'rails_helper'

describe Person do
  let(:realm) { Person::MIN_REALM.upto(Person::MAX_REALM).to_a.sample }

  context "#name" do
    let(:mum) { create(:person, first_names: "Ruth Patricia Legard", known_as: "Pat", last_name: "Algeo", born: 1927, married_name: "Orr", male: false, realm: realm) }
    let(:dad) { create(:person, first_names: "John", known_as: "John", last_name: "Orr", born: 1931, died: 2015, male: true, realm: realm) }

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
      expect(mum.name(reversed: false, full: true, with_known_as: true, with_years: true, brackets: true)).to eq "Ruth Patricia Legard (Pat) Algeo (1927)"
      expect(dad.name(reversed: false, full: true, with_known_as: true, with_years: true, brackets: true)).to eq "John Orr (1931-2015)"
    end

    it "normal, full, with known as, with married name" do
      expect(mum.name(reversed: false, full: true, with_known_as: true, with_married_name: true)).to eq "Ruth Patricia Legard (Pat) Algeo (Orr)"
      expect(dad.name(reversed: false, full: true, with_known_as: true, with_married_name: true)).to eq "John Orr"
    end
  end

  context "#relationship" do
    let!(:thomas)  { create(:person, born: 1900, male: true, first_names: "Thomas", realm: realm) }
    let!(:mona)    { create(:person, born: 1901, male: false, first_names: "Mona", realm: realm) }
    let!(:pat)     { create(:person, born: 1927, male: false, father: thomas, mother: mona, first_names: "Pat", realm: realm) }
    let!(:tom)     { create(:person, born: 1935, male: true, died: 1998, father: thomas, mother: mona, first_names: "Tom", realm: realm) }
    let!(:june)    { create(:person, born: 1937, male: false, father: thomas, mother: mona, first_names: "June", realm: realm) }
    let!(:doug)    { create(:person, born: 1939, male: true, died: 2023, father: thomas, mother: mona, first_names: "Doug", realm: realm) }
    let!(:gerry)   { create(:person, born: 1936, male: true, first_names: "Gerry", realm: realm) }
    let!(:william) { create(:person, born: 1885, male: true, first_names: "William", realm: realm) }
    let!(:marlene) { create(:person, born: 1907, male: false, first_names: "Marlene", realm: realm) }
    let!(:john)    { create(:person, born: 1930, male: true, father: william, mother: marlene, first_names: "John", realm: realm) }
    let!(:joe)     { create(:person, born: 1940, male: true, father: william, mother: marlene, first_names: "Joe", realm: realm) }
    let!(:lily)    { create(:person, born: 1935, male: false, first_names: "Lily", realm: realm) }
    let!(:beth)    { create(:person, born: 1935, male: false, father: william, mother: marlene, first_names: "Beth", realm: realm) }
    let!(:jean)    { create(:person, born: 1929, male: false, father: william, mother: marlene, first_names: "Jean", realm: realm) }
    let!(:mark)    { create(:person, born: 1955, male: true, father: john, mother: pat, first_names: "Mark", realm: realm) }
    let!(:sandra)  { create(:person, born: 1957, male: false, first_names: "Sandra", realm: realm) }
    let!(:malc)    { create(:person, born: 1957, male: true, father: john, mother: pat, first_names: "Malc", realm: realm) }
    let!(:al)      { create(:person, born: 1960, male: false, first_names: "Al", realm: realm) }
    let!(:ross)    { create(:person, born: 1990, male: true, mother: al, first_names: "Ross", realm: realm) }
    let!(:kirk)    { create(:person, born: 1967, male: true, father: gerry, mother: june, first_names: "Kirk", realm: realm) }
    let!(:paula)   { create(:person, born: 1967, male: false, father: doug, first_names: "Paula", realm: realm) }
    let!(:penny)   { create(:person, born: 1986, male: false, father: mark, first_names: "Penny", realm: realm) }
    let!(:faye)    { create(:person, born: 1986, male: false, father: malc, first_names: "Faye", realm: realm) }
    let!(:tracey)  { create(:person, born: 1980, male: false, father: malc, first_names: "Tracey", realm: realm) }
    let!(:jamie)   { create(:person, born: 1986, male: true, father: kirk, first_names: "Jamie", realm: realm) }
    let!(:ge_ju)   { create(:partnership, wedding: 1960, marriage: true, husband: gerry, wife: june, realm: realm) }
    let!(:jo_li)   { create(:partnership, wedding: 1950, marriage: true, husband: joe, wife: lily, realm: realm) }
    let!(:jo_pa)   { create(:partnership, wedding: 1950, marriage: true, husband: john, wife: pat, realm: realm, divorce: 2024) }
    let!(:ma_al)   { create(:partnership, wedding: 1990, marriage: true, husband: malc, wife: al, realm: realm) }
    let!(:ma_sa)   { create(:partnership, wedding: 1994, marriage: true, husband: mark, wife: sandra, realm: realm) }
    let!(:th_mo)   { create(:partnership, wedding: 1925, marriage: true, husband: thomas, wife: mona, realm: realm) }
    let!(:wm_ma)   { create(:partnership, wedding: 1927, marriage: false, husband: william, wife: marlene, realm: realm) }

    it "self" do
      expect(thomas.relationship(thomas).to_s).to eq "is the same as"
      expect(june.relationship(june).to_s).to eq "is the same as"
    end

    it "father/son/mother/daughter" do
      expect(thomas.relationship(tom).to_s).to eq "is the father of"
      expect(doug.relationship(thomas).to_s).to eq "was a son of"
      expect(mona.relationship(pat).to_s).to eq "is the mother of"
      expect(pat.relationship(mona).to_s).to eq "is a daughter of"
    end

    it "brother/sister" do
      expect(joe.relationship(john).to_s).to eq "is a brother of"
      expect(john.relationship(joe).to_s).to eq "is a brother of"
      expect(beth.relationship(jean).to_s).to eq "is a sister of"
      expect(jean.relationship(beth).to_s).to eq "is a sister of"
      expect(tom.relationship(pat).to_s).to eq "was a brother of"
      expect(pat.relationship(tom).to_s).to eq "is a sister of"
    end

    it "grandfather/grandson/grandmother/granddaughter" do
      expect(thomas.relationship(mark).to_s).to eq "is a grandfather of"
      expect(kirk.relationship(mona).to_s).to eq "is a grandson of"
      expect(mona.relationship(kirk).to_s).to eq "is a grandmother of"
      expect(paula.relationship(mona).to_s).to eq "is a granddaughter of"
      expect(penny.relationship(thomas).to_s).to eq "is a great-granddaughter of"
      expect(mona.relationship(jamie).to_s).to eq "is a great-grandmother of"
      expect(jamie.relationship(mona).to_s).to eq "is a great-grandson of"
      expect(thomas.relationship(penny).to_s).to eq "is a great-grandfather of"
    end

    it "uncle/aunt/nephew/niece" do
      expect(tom.relationship(kirk).to_s).to eq "was an uncle of"
      expect(beth.relationship(malc).to_s).to eq "is an aunt of"
      expect(malc.relationship(beth).to_s).to eq "is a nephew of"
      expect(faye.relationship(mark).to_s).to eq "is a niece of"
      expect(jamie.relationship(doug).to_s).to eq "is a great-nephew of"
      expect(doug.relationship(jamie).to_s).to eq "was a great-uncle of"
      expect(penny.relationship(june).to_s).to eq "is a great-niece of"
      expect(june.relationship(penny).to_s).to eq "is a great-aunt of"
    end

    it "cousin" do
      expect(mark.relationship(kirk).to_s).to eq "is a 1st cousin of"
      expect(kirk.relationship(mark).to_s).to eq "is a 1st cousin of"
      expect(penny.relationship(faye).to_s).to eq "is a 1st cousin of"
      expect(faye.relationship(penny).to_s).to eq "is a 1st cousin of"
      expect(malc.relationship(jamie).to_s).to eq "is a 1st cousin once removed of"
      expect(jamie.relationship(malc).to_s).to eq "is a 1st cousin once removed of"
      expect(penny.relationship(kirk).to_s).to eq "is a 1st cousin once removed of"
      expect(kirk.relationship(penny).to_s).to eq "is a 1st cousin once removed of"
      expect(penny.relationship(jamie).to_s).to eq "is a 2nd cousin of"
      expect(jamie.relationship(penny).to_s).to eq "is a 2nd cousin of"
    end

    it "husband/wife/partner" do
      expect(thomas.relationship(mona).to_s).to eq "is the husband of"
      expect(mona.relationship(thomas).to_s).to eq "is the wife of"
      expect(mark.relationship(sandra).to_s).to eq "is the husband of"
      expect(sandra.relationship(mark).to_s).to eq "is the wife of"
      expect(pat.relationship(john).to_s).to eq "was the wife of"
      expect(william.relationship(marlene).to_s).to eq "is the partner of"
    end

    it "father/son/mother/daughter by marriage" do
      expect(john.relationship(sandra).to_s).to eq "is a father-in-law of"
      expect(marlene.relationship(pat).to_s).to eq "is a mother-in-law of"
      expect(john.relationship(mona).to_s).to eq "is a son-in-law of"
      expect(al.relationship(pat).to_s).to eq "is a daughter-in-law of"
    end

    it "step father/son/mother/daughter" do
      expect(malc.relationship(ross).to_s).to eq "is a step-father of"
      expect(ross.relationship(malc).to_s).to eq "is a step-son of"
      expect(sandra.relationship(penny).to_s).to eq "is a step-mother of"
      expect(penny.relationship(sandra).to_s).to  eq "is a step-daughter of"
    end

    it "step brother/sister" do
      expect(ross.relationship(tracey).to_s).to eq "is a step-brother of"
      expect(faye.relationship(ross).to_s).to eq "is a step-sister of"
    end

    it "brother/sister by marriage" do
      expect(malc.relationship(sandra).to_s).to eq "is a brother-in-law of"
      expect(john.relationship(gerry).to_s).to eq "is a brother-in-law of"
      expect(pat.relationship(lily).to_s).to eq "is a sister-in-law of"
      expect(lily.relationship(beth).to_s).to eq "is a sister-in-law of"
    end

    it "uncle/aunt/nephew/niece by marriage" do
      expect(gerry.relationship(mark).to_s).to eq "is an uncle of"
      expect(malc.relationship(gerry).to_s).to eq "is a nephew of"
      expect(lily.relationship(mark).to_s).to eq "is an aunt of"
      expect(faye.relationship(sandra).to_s).to eq "is a niece of"
    end

    it "no relation" do
      expect(thomas.relationship(william).to_s).to eq "is no relation of"
      expect(mona.relationship(marlene).to_s).to eq "is no relation of"
    end
  end

  context "#partners" do
    let!(:mark)      { create(:person, born: 1955, male: true, realm: realm) }
    let!(:lynda)     { create(:person, born: 1967, male: false, realm: realm) }
    let!(:aphrodite) { create(:person, born: 1969, male: false, realm: realm) }
    let!(:pat)       { create(:person, born: 1942, male: false, realm: realm) }
    let!(:m_a)       { create(:partnership, husband: mark, wedding: 1988, marriage: false, wife: aphrodite, realm: realm) }
    let!(:m_p)       { create(:partnership, husband: mark, wedding: 1989, marriage: false, wife: pat, realm: realm) }
    let!(:m_l)       { create(:partnership, husband: mark, wedding: 1990, marriage: false, wife: lynda, realm: realm) }

    it "order by partnership start, not partner age" do
      expect(mark.partners.map(&:id)).to eq [aphrodite.id, pat.id, lynda.id]
    end
  end

  context "#siblings" do
    let!(:terry)     { create(:person, born: 1930, male: true, realm: realm) }
    let!(:anne)      { create(:person, born: 1930, male: false, realm: realm) }
    let!(:elma)      { create(:person, born: 1934, male: false, realm: realm) }
    let!(:jonathan)  { create(:person, born: 1960, male: true, father: terry, mother: anne, realm: realm) }
    let!(:stuart)    { create(:person, born: 1966, male: true, father: terry, mother: elma, realm: realm) }
    let!(:ishbel)    { create(:person, born: 1969, male: false, father: terry, mother: elma, realm: realm) }
    let!(:helen)     { create(:person, born: 1971, male: false, father: terry, mother: elma, realm: realm) }

    it "all siblings" do
      expect(terry.siblings.map(&:id)).to eq []
      expect(anne.siblings.map(&:id)).to eq []
      expect(elma.siblings.map(&:id)).to eq []
      expect(jonathan.siblings.map(&:id)).to eq [stuart.id, ishbel.id, helen.id]
      expect(stuart.siblings.map(&:id)).to eq [jonathan.id, ishbel.id, helen.id]
      expect(ishbel.siblings.map(&:id)).to eq [jonathan.id, stuart.id, helen.id]
      expect(helen.siblings.map(&:id)).to eq [jonathan.id, stuart.id, ishbel.id]
    end

    it "full siblings" do
      expect(jonathan.siblings(full: true).map(&:id)).to eq []
      expect(stuart.siblings(full: true).map(&:id)).to eq [ishbel.id, helen.id]
      expect(ishbel.siblings(full: true).map(&:id)).to eq [stuart.id, helen.id]
      expect(helen.siblings(full: true).map(&:id)).to eq [stuart.id, ishbel.id]
    end

    it "older siblings" do
      expect(jonathan.siblings(younger: true).map(&:id)).to eq [stuart.id, ishbel.id, helen.id]
      expect(stuart.siblings(younger: true).map(&:id)).to eq [ishbel.id, helen.id]
      expect(ishbel.siblings(younger: true).map(&:id)).to eq [helen.id]
      expect(helen.siblings(younger: true).map(&:id)).to eq []
    end

    it "older siblings" do
      expect(jonathan.siblings(older: true).map(&:id)).to eq []
      expect(stuart.siblings(older: true).map(&:id)).to eq [jonathan.id]
      expect(ishbel.siblings(older: true).map(&:id)).to eq [jonathan.id, stuart.id]
      expect(helen.siblings(older: true).map(&:id)).to eq [jonathan.id, stuart.id, ishbel.id]
    end

    it "full younger siblings" do
      expect(jonathan.siblings(full: true, younger: true).map(&:id)).to eq []
      expect(stuart.siblings(full: true, younger: true).map(&:id)).to eq [ishbel.id, helen.id]
      expect(ishbel.siblings(full: true, younger: true).map(&:id)).to eq [helen.id]
      expect(helen.siblings(full: true, younger: true).map(&:id)).to eq []
    end

    it "full older siblings" do
      expect(jonathan.siblings(full: true, older: true).map(&:id)).to eq []
      expect(stuart.siblings(full: true, older: true).map(&:id)).to eq []
      expect(ishbel.siblings(full: true, older: true).map(&:id)).to eq [stuart.id]
      expect(helen.siblings(full: true, older: true).map(&:id)).to eq [stuart.id, ishbel.id]
    end
  end

  context "destruction" do
    let!(:terry)     { create(:person, born: 1930, male: true, realm: realm) }
    let!(:anne)      { create(:person, born: 1930, male: false, realm: realm) }
    let!(:elma)      { create(:person, born: 1934, male: false, realm: realm) }
    let!(:t_a)       { create(:partnership, husband: terry, wedding: 1959, wife: anne, realm: realm) }
    let!(:t_e)       { create(:partnership, husband: terry, wedding: 1965, wife: elma, realm: realm) }
    let!(:jonathan)  { create(:person, born: 1960, male: true, father: terry, mother: anne, realm: realm) }
    let!(:stuart)    { create(:person, born: 1966, male: true, father: terry, mother: elma, realm: realm) }
    let!(:ishbel)    { create(:person, born: 1969, male: false, father: terry, mother: elma, realm: realm) }
    let!(:helen)     { create(:person, born: 1971, male: false, father: terry, mother: elma, realm: realm) }

    it "husband => partnership" do
      expect(Partnership.count).to eq 2
      terry.destroy
      expect(Partnership.count).to eq 0
    end

    it "wife => partnership" do
      expect(Partnership.count).to eq 2
      anne.destroy
      expect(Partnership.count).to eq 1
      elma.destroy
      expect(Partnership.count).to eq 0
    end

    it "father => child relationships" do
      terry.destroy
      [jonathan, stuart, ishbel, helen].each do |p|
        p.reload
        expect(p.father_id).to be_nil
        expect(p.mother_id).to_not be_nil
      end
    end

    it "mother => child relationships" do
      anne.destroy
      [jonathan, stuart, ishbel, helen].each do |p|
        p.reload
        expect(p.mother_id).to eq p.id == jonathan.id ? nil : elma.id
        expect(p.father_id).to_not be_nil
      end
      elma.destroy
      [jonathan, stuart, ishbel, helen].each do |p|
        p.reload
        expect(p.mother_id).to be_nil
        expect(p.father_id).to_not be_nil
      end
    end
  end
end
