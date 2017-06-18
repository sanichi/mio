require 'rails_helper'

describe Kanji do
  it "kanji, readings and yomi" do
    k = Kanji.create(symbol: "木", meaning: "tree")
    r = Reading.find_or_create_by(kana: "もく")
    y = Yomi.create(kanji: k, reading: r, on: true)

    expect(Kanji.count).to eq 1
    expect(Reading.count).to eq 1
    expect(Yomi.count).to eq 1

    expect(k.onyomi).to eq 1
    expect(k.kunyomi).to eq 0
    expect(r.onyomi).to eq 1
    expect(r.kunyomi).to eq 0

    r = Reading.find_or_create_by(kana: "き")
    y = Yomi.create(kanji: k, reading: r, on: false)

    expect(Kanji.count).to eq 1
    expect(Reading.count).to eq 2
    expect(Yomi.count).to eq 2

    expect(k.onyomi).to eq 1
    expect(k.kunyomi).to eq 1
    expect(r.onyomi).to eq 0
    expect(r.kunyomi).to eq 1

    k = Kanji.create(symbol: "気", meaning: "energy")
    r = Reading.find_or_create_by(kana: "き")
    y = Yomi.create(kanji: k, reading: r, on: true)

    expect(Kanji.count).to eq 2
    expect(Reading.count).to eq 2
    expect(Yomi.count).to eq 3

    expect(k.onyomi).to eq 1
    expect(k.kunyomi).to eq 0
    expect(r.onyomi).to eq 1
    expect(r.kunyomi).to eq 1

    k = Kanji.find_or_create_by(symbol: "目", meaning: "eye")
    r = Reading.find_or_create_by(kana: "もく")
    y = Yomi.create(kanji: k, reading: r, on: true)

    expect(Kanji.count).to eq 3
    expect(Reading.count).to eq 2
    expect(Yomi.count).to eq 4

    expect(k.onyomi).to eq 1
    expect(k.kunyomi).to eq 0
    expect(r.onyomi).to eq 2
    expect(r.kunyomi).to eq 0
  end
end
