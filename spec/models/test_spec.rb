require 'rails_helper'

describe Test do
  let!(:e1) { create(:wk_example) }
  let!(:e2) { create(:wk_example) }
  let!(:e3) { create(:wk_example) }
  let!(:p1) { create(:place, category: "prefecture") }
  let!(:p2) { create(:place, category: "prefecture") }
  let!(:b1) { create(:border, from: p1, to: p2) }

  it "start" do
    expect(Test.count).to eq 6
  end

  context "creation" do
    it "examples" do
      expect(Wk::Example.count).to eq 3
      expect(Test.where(testable_type: "Wk::Example").count).to eq 3
      [e1.test, e2.test, e3.test].each do |s|
        expect(s.attempts).to eq 0
        expect(s.poor).to eq 0
        expect(s.fair).to eq 0
        expect(s.good).to eq 0
        expect(s.excellent).to eq 0
        expect(s.level).to eq 0
        expect(s.due).to be_nil
      end
    end

    it "borders" do
      expect(Border.count).to eq 1
      expect(Test.where(testable_type: "Border").count).to eq 1
      s = b1.test
      expect(s.attempts).to eq 0
      expect(s.poor).to eq 0
      expect(s.fair).to eq 0
      expect(s.good).to eq 0
      expect(s.excellent).to eq 0
      expect(s.level).to eq 0
      expect(s.due).to be_nil
    end

    it "places" do
      expect(Place.count).to eq 2
      expect(Test.where(testable_type: "Place").count).to eq 2
      [p1.test, p2.test].each do |s|
        expect(s.attempts).to eq 0
        expect(s.poor).to eq 0
        expect(s.fair).to eq 0
        expect(s.good).to eq 0
        expect(s.excellent).to eq 0
        expect(s.level).to eq 0
        expect(s.due).to be_nil
      end
    end
  end

  context "deletion" do
    it "examples" do
      [e1, e2, e3].each { |e| e.destroy }
      expect(Test.where(testable_type: "Wk::Example").count).to eq 0
      expect(Test.count).to eq 3
    end

    it "borders" do
      b1.destroy
      expect(Test.where(testable_type: "Border").count).to eq 0
      expect(Test.count).to eq 5
    end

    # note: deleting places deletes their borders which in turn deletes any border tests
    it "places" do
      [p1, p2].each { |p| p.destroy }
      expect(Test.where(testable_type: "Place").count).to eq 0
      expect(Test.where(testable_type: "Border").count).to eq 0
      expect(Test.count).to eq 3
    end
  end
end
