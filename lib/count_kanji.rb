# reset all the kanji frequency counts to zero
Kanji.update_all(frequency: 0)

# loop through all vocab kanjis
Vocab.pluck(:kanji).each do |kanji|
  kanji.split('').map do |c|
    if (k = Kanji.find_by(symbol: c))
      k.update_column(:frequency, k.frequency + 1)
    end
  end
end
