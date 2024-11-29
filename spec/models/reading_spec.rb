require 'rails_helper'

describe Wk::Reading do
  let(:reading) { create(:wk_reading, characters: "いちにち", primary: true) }

  context "save" do
    it "no accent" do
      expect(reading.accent_pattern).to be_nil
      expect(reading.accent_position).to be_nil
    end

    it "unknown" do
      reading.accent_position = -1
      reading.save
      expect(reading.accent_position).to eq -1
      expect(reading.accent_pattern).to be_nil
    end

    it "heiban" do
      reading.accent_position = 0
      reading.save
      expect(reading.accent_position).to eq 0
      expect(reading.accent_pattern).to eq Wk::Reading::HEIBAN
    end

    it "atamadaka" do
      reading.accent_position = 1
      reading.save
      expect(reading.accent_position).to eq 1
      expect(reading.accent_pattern).to eq Wk::Reading::ATAMADAKA
    end

    it "nakadaka" do
      reading.accent_position = 2
      reading.save
      expect(reading.accent_position).to eq 2
      expect(reading.accent_pattern).to eq Wk::Reading::NAKADAKA
    end

    it "odaka" do
      reading.accent_position = 4
      reading.save
      expect(reading.accent_position).to eq 4
      expect(reading.accent_pattern).to eq Wk::Reading::ODAKA
    end
  end

  context "update_accent" do
    it "no accent" do
      reading.update_accent("?")
      expect(reading.accent_pattern).to be_nil
      expect(reading.accent_position).to be_nil
    end

    it "unknown" do
      reading.update_accent("-")
      expect(reading.accent_position).to eq -1
      expect(reading.accent_pattern).to be_nil
    end

    it "heiban" do
      reading.update_accent("0")
      expect(reading.accent_position).to eq 0
      expect(reading.accent_pattern).to eq Wk::Reading::HEIBAN
    end

    it "atamadaka" do
      reading.update_accent("1")
      expect(reading.accent_position).to eq 1
      expect(reading.accent_pattern).to eq Wk::Reading::ATAMADAKA
    end

    it "nakadaka" do
      reading.update_accent("3")
      expect(reading.accent_position).to eq 3
      expect(reading.accent_pattern).to eq Wk::Reading::NAKADAKA
    end

    it "odaka" do
      reading.update_accent("4")
      expect(reading.accent_position).to eq 4
      expect(reading.accent_pattern).to eq Wk::Reading::ODAKA
    end
  end
end
