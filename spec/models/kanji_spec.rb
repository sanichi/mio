require 'rails_helper'

describe Kanji do
  it "create kanjis, readings and yomis" do
    k = Kanji.create!(symbol: "木", meaning: "tree", level: 2)
    expect(k.check_reading_data("もく", "き,こ", "onyomi")).to be_nil
    expect(k.create_readings).to be_nil

    expect(Kanji.count).to eq 1
    expect(Reading.count).to eq 3
    expect(Yomi.count).to eq 3
    expect(k.onyomi).to eq 1
    expect(k.kunyomi).to eq 2
    r = k.readings.sort_by{ |r| r.kana }
    expect(r.size).to eq 3
    expect(r[0].kana).to eq "き"
    expect(r[0].onyomi).to eq 0
    expect(r[0].kunyomi).to eq 1
    expect(r[1].kana).to eq "こ"
    expect(r[1].onyomi).to eq 0
    expect(r[1].kunyomi).to eq 1
    expect(r[2].kana).to eq "もく"
    expect(r[2].onyomi).to eq 1
    expect(r[2].kunyomi).to eq 0
    y = k.yomis.sort_by{ |y| y.reading.kana }
    expect(y.size).to eq 3
    expect(y[0].on).to be false
    expect(y[0].important).to be false
    expect(y[1].on).to be false
    expect(y[1].important).to be false
    expect(y[2].on).to be true
    expect(y[2].important).to be true

    k = Kanji.create!(symbol: "目", meaning: "eye", level: 2)
    expect(k.check_reading_data("もく", "め", "kunyomi")).to be_nil
    expect(k.create_readings).to be_nil

    expect(Kanji.count).to eq 2
    expect(Reading.count).to eq 4
    expect(Yomi.count).to eq 5
    expect(k.onyomi).to eq 1
    expect(k.kunyomi).to eq 1
    r = k.readings.sort_by{ |r| r.kana }
    expect(r.size).to eq 2
    expect(r[0].kana).to eq "め"
    expect(r[0].onyomi).to eq 0
    expect(r[0].kunyomi).to eq 1
    expect(r[1].kana).to eq "もく"
    expect(r[1].onyomi).to eq 2
    expect(r[1].kunyomi).to eq 0
    y = k.yomis.sort_by{ |y| y.reading.kana }
    expect(y.size).to eq 2
    expect(y[0].on).to be false
    expect(y[0].important).to be true
    expect(y[1].on).to be true
    expect(y[1].important).to be false

    k = Kanji.create!(symbol: "紀", meaning: "account, narrative", level: 15)
    expect(k.check_reading_data("き", nil, "onyomi")).to be_nil
    expect(k.create_readings).to be_nil

    expect(Kanji.count).to eq 3
    expect(Reading.count).to eq 4
    expect(Yomi.count).to eq 6
    expect(k.onyomi).to eq 1
    expect(k.kunyomi).to eq 0
    r = k.readings.sort_by{ |r| r.kana }
    expect(r.size).to eq 1
    expect(r[0].kana).to eq "き"
    expect(r[0].onyomi).to eq 1
    expect(r[0].kunyomi).to eq 1
    y = k.yomis.sort_by{ |y| y.reading.kana }
    expect(y.size).to eq 1
    expect(y[0].on).to be true
    expect(y[0].important).to be true
  end

  it "update kanjis, readings and yomis" do
    Kanji.create!(symbol: "木", meaning: "tree", level: 2).yield_self do |k|
      k.check_reading_data("もく", "き,こ", "onyomi")
      k.create_readings
    end
    Kanji.create!(symbol: "目", meaning: "eye", level: 2).yield_self do |k|
      k.check_reading_data("もく", "め", "kunyomi")
      k.create_readings
    end
    Kanji.create!(symbol: "紀", meaning: "account, narrative", level: 15).yield_self do |k|
      k.check_reading_data("き", nil, "onyomi")
      k.create_readings
    end

    expect(Kanji.count).to eq 3
    expect(Reading.count).to eq 4
    expect(Yomi.count).to eq 6

    k = Kanji.find_by(symbol: "木")
    expect(k.check_reading_data("もく", "き,こ", "onyomi")).to be_nil
    expect(k.readings_change).to be_nil
    expect(k.create_readings(test: true, update: true)).to be_nil

    expect(Reading.count).to eq 4
    expect(Yomi.count).to eq 6

    k = Kanji.find_by(symbol: "目")
    expect(k.check_reading_data("もく", "め, き", "kunyomi")).to be_nil
    expect(k.readings_change).to eq "もく|め|kunyomi => もく|き,め|kunyomi"
    expect(k.create_readings(update: true)).to be_nil
    k.reload

    expect(Reading.count).to eq 4
    expect(Yomi.count).to eq 7
    r = k.readings.sort_by{ |r| r.kana }
    expect(r.size).to eq 3
    expect(r[0].kana).to eq "き"
    expect(r[0].onyomi).to eq 1
    expect(r[0].kunyomi).to eq 2
    expect(r[1].kana).to eq "め"
    expect(r[1].onyomi).to eq 0
    expect(r[1].kunyomi).to eq 1
    expect(r[2].kana).to eq "もく"
    expect(r[2].onyomi).to eq 2
    expect(r[2].kunyomi).to eq 0
    y = k.yomis.sort_by{ |y| y.reading.kana }
    expect(y.size).to eq 3
    expect(y[0].on).to be false
    expect(y[0].important).to be true
    expect(y[1].on).to be false
    expect(y[1].important).to be true
    expect(y[2].on).to be true
    expect(y[2].important).to be false

    k = Kanji.find_by(symbol: "木")
    expect(k.check_reading_data("もく", "き", "onyomi")).to be_nil
    expect(k.readings_change).to eq "もく|き,こ|onyomi => もく|き|onyomi"
    expect(k.create_readings(update: true)).to be_nil
    k.reload

    expect(Reading.count).to eq 3
    expect(Yomi.count).to eq 6
    r = k.readings.sort_by{ |r| r.kana }
    expect(r.size).to eq 2
    expect(r[0].kana).to eq "き"
    expect(r[0].onyomi).to eq 1
    expect(r[0].kunyomi).to eq 2
    expect(r[1].kana).to eq "もく"
    expect(r[1].onyomi).to eq 2
    expect(r[1].kunyomi).to eq 0
    y = k.yomis.sort_by{ |y| y.reading.kana }
    expect(y.size).to eq 2
    expect(y[0].on).to be false
    expect(y[0].important).to be false
    expect(y[1].on).to be true
    expect(y[1].important).to be true

    k = Kanji.find_by(symbol: "紀")
    expect(k.check_reading_data("", "き", "kunyomi")).to be_nil
    expect(k.readings_change).to eq "き||onyomi => |き|kunyomi"
    expect(k.create_readings(update: true)).to be_nil
    k.reload

    expect(Reading.count).to eq 3
    expect(Yomi.count).to eq 6
    r = k.readings.sort_by{ |r| r.kana }
    expect(r.size).to eq 1
    expect(r[0].kana).to eq "き"
    expect(r[0].onyomi).to eq 0
    expect(r[0].kunyomi).to eq 3
    y = k.yomis.sort_by{ |y| y.reading.kana }
    expect(y.size).to eq 1
    expect(y[0].on).to be false
    expect(y[0].important).to be true

    k = Kanji.find_by(symbol: "目")
    expect(k.check_reading_data("もく", "き", "kunyomi")).to be_nil
    expect(k.readings_change).to eq "もく|き,め|kunyomi => もく|き|kunyomi"
    expect(k.create_readings(update: true)).to be_nil
    k.reload

    expect(Reading.count).to eq 2
    expect(Yomi.count).to eq 5
    r = k.readings.sort_by{ |r| r.kana }
    expect(r.size).to eq 2
    expect(r[0].kana).to eq "き"
    expect(r[0].onyomi).to eq 0
    expect(r[0].kunyomi).to eq 3
    expect(r[1].kana).to eq "もく"
    expect(r[1].onyomi).to eq 2
    expect(r[1].kunyomi).to eq 0
    y = k.yomis.sort_by{ |y| y.reading.kana }
    expect(y.size).to eq 2
    expect(y[0].on).to be false
    expect(y[0].important).to be true
    expect(y[1].on).to be true
    expect(y[1].important).to be false
  end

  it "errors" do
    k = Kanji.create!(symbol: "木", meaning: "tree", level: 2)
    expect(k.check_reading_data("もく", "き,こ", nil)).to_not be_nil
    expect(k.check_reading_data("", "き,こ", "onyomi")).to_not be_nil
    expect(k.check_reading_data("もく", "", "kunyomi")).to_not be_nil
    expect(k.check_reading_data("", "", "kunyomi")).to_not be_nil
  end
end
