require 'rails_helper'

describe Person do
  context "#name" do
    let(:mum) { create(:person, first_names: "Ruth Patricia Legard", known_as: "Pat", last_name: "Algeo") }
    let(:dad) { create(:person, first_names: "John", known_as: "John", last_name: "Orr") }

    it "default" do
      expect(mum.name).to eq "Algeo, Ruth Patricia Legard"
      expect(dad.name).to eq "Orr, John"
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
end
