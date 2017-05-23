require 'wani_kani'

begin
  # Give log messages a bit of context.
  puts Date.today

  # Get the kanji of the current vocabs from the DB.
  db_kanji = Vocab.pluck(:kanji)
  puts "current count in #{Rails.env} DB: #{db_kanji.size}"

  # Get the kanji of the current user vocabs from WaniKani.
  wk = WaniKani.new(Rails.application.secrets.wani_kani)
  wk_kanji = wk.kanji
  puts "current count of user vocabulary: #{wk_kanji.size}"

  # Get a list of vocab we don't have yet.
  new_kanji = wk_kanji - db_kanji
  puts "new vocabulary to retreive: #{new_kanji.size}"
  exit(true) unless new_kanji.any?

  # Loop over the new kanji.
  new_kanji.each do |kanji|
    # Get the API data for this vocab.
    data = wk.vocab[kanji]

    # Scrape data that isn't returned by the API from the website for this vocab.
    audio, category = wk.scrape(kanji)

    # Store all the new data in the DB.
    Vocab.create!(audio: audio, category: category, kanji: kanji, level: data["level"], meaning: data["meaning"], reading: data["kana"])
  end

  # Feedback about number created.
  puts "new vocabs created: #{new_kanji.size} (from #{new_kanji.first} to #{new_kanji.last})"
rescue => e
  # Feedback if there is an error.
  puts "exception: #{e.message}"
end
