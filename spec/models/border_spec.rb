require 'rails_helper'

describe Border do
  let(:data) { build(:border) }
  let(:p1)   { create(:place, category: "prefecture") }
  let(:p2)   { create(:place, category: "prefecture") }
  let(:p3)   { create(:place, category: "prefecture") }

  context "valid" do
    it "create" do
      b1 = Border.create!(from: p1, to: p2, direction: data.direction)
      expect(b1.direction).to eq data.direction
      expect(b1.from).to eq p1
      expect(b1.to).to eq p2

      b2 = Border.create!(from: p1, to: p3, direction: Border.opposite(data.direction))
      expect(b2.direction).to eq Border.opposite(data.direction)
      expect(b2.from).to eq p1
      expect(b2.to).to eq p3

      expect(p1.borders.count).to eq 2
      expect(p1.borders.map(&:to).include?(p2)).to be true
      expect(p1.borders.map(&:to).include?(p3)).to be true
      expect(p1.neighbours.count).to eq 2
      expect(p1.neighbours.include?(p2)).to be true
      expect(p1.neighbours.include?(p3)).to be true

      expect(p2.borders.count).to eq 0
      expect(p2.neighbours.count).to eq 0
      expect(p3.borders.count).to eq 0
      expect(p3.neighbours.count).to eq 0
    end

    it "with IDs" do
      b = Border.create!(from_id: p1.id, to_id: p2.id, direction: data.direction)
      expect(b.from).to eq p1
      expect(b.to).to eq p2
    end
  end

  context "invalid" do
    let(:c1) { create(:place, category: "city") }
    let(:r1) { create(:place, category: "region") }

    it "no self border" do
      expect { Border.create!(from: p1, to: p1, direction: data.direction) }.to raise_error(/must be distinct/)
    end

    it "no neighbour duplicates" do
      expect { Border.create!(from: p1, to: p2, direction: data.direction) }.to_not raise_error
      expect { Border.create!(from: p1, to: p2, direction: data.direction) }.to raise_error(/already been taken/)
    end

    it "no direction duplicates" do
      expect { Border.create!(from: p1, to: p2, direction: data.direction) }.to_not raise_error
      expect { Border.create!(from: p1, to: p3, direction: data.direction) }.to raise_error(/already been taken/)
    end

    it "only prefectures" do
      expect { Border.create!(from: p1, to: c1, direction: data.direction) }.to raise_error(/not a prefecture/)
      expect { Border.create!(from: r1, to: p2, direction: data.direction) }.to raise_error(/not a prefecture/)
      expect { Border.create!(from: r1, to: c1, direction: data.direction) }.to raise_error(/not a prefecture/)
    end
  end
end
