require 'wani_kani'

def update_vocabs(wk)
  # Get the kanji of the current vocabs from the DB.
  db_vocabs = Vocab.pluck(:kanji)
  puts "current count of vocabs in #{Rails.env} DB: #{db_vocabs.size}"

  # Get the  user's vocabs from WaniKani.
  wk_vocabs = wk.vocabs
  puts "current count of user vocabulary: #{wk_vocabs.size}"

  # Warn about excess vocabs.
  excess_vocabs = db_vocabs - wk_vocabs
  puts "excess vocabs (#{excess_vocabs.size}): #{excess_vocabs.join(', ')}" if excess_vocabs.any?

  # Get a list of vocab we don't have yet.
  new_vocabs = wk_vocabs - db_vocabs
  puts "new vocabulary to retreive: #{new_vocabs.size}"
  return unless new_vocabs.any?

  # Note the number of vocabs now.
  vocab_count = Vocab.count

  # Get a progress bar.
  progress = ProgressBar.create(title: "Vocabs", total: new_vocabs.size, output: STDOUT)

  # Loop over the new vocabs.
  new_vocabs.each do |vocab|
    # Get the API data for this vocab.
    data = wk.vocab[vocab]

    # Scrape data that isn't returned by the API from the website for this vocab.
    audio, category = wk.scrape(vocab)

    # Store all the new data in the DB.
    Vocab.create!(audio: audio, category: category, kanji: vocab, level: data["level"], meaning: data["meaning"], reading: data["kana"])

    # Update progress.
    progress.increment
  end

  # Feedback about number created.
  puts "new vocabs created: #{Vocab.count - vocab_count}"
end

def update_kanjis(wk)
  # Get the symbols of the current kanji from the DB.
  db_kanjis = Kanji.pluck(:symbol)
  puts "current count of kanji in #{Rails.env} DB: #{db_kanjis.size}"

  # Get the user's kanji from WaniKani.
  wk_kanjis = wk.kanjis
  puts "current count of user kanji: #{wk_kanjis.size}"

  # Warn about excess kanji.
  excess_kanjis = db_kanjis - wk_kanjis
  puts "excess kanji (#{excess_kanjis.size}): #{excess_kanjis.join(', ')}" if excess_kanjis.any?

  # Get a list of kanji we don't have yet.
  new_kanjis = wk_kanjis - db_kanjis
  puts "new kanji to retreive: #{new_kanjis.size}"
  return unless new_kanjis.any?

  # Note the number of releavant objects now.
  kanji_count = Kanji.count
  reading_count = Reading.count
  yomi_count = Yomi.count

  # Get a progress bar.
  progress = ProgressBar.create(title: "Kanji", total: new_kanjis.size, output: STDOUT)

  # Loop over the new kanji.
  new_kanjis.each do |kanji|
    # Get the API data for this kanji.
    data = wk.kanji[kanji]

    # Create a new kanji object.
    k = Kanji.create(symbol: kanji, meaning: data["meaning"])

    # Organise the WaniKani reading data.
    onyomi = data["onyomi"].to_s.gsub(/[\sa-zA-Z\/.*]/, "").split(",")
    kunyomi = data["kunyomi"].to_s.gsub(/[\sa-zA-Z\/.*]/, "").split(",")
    die "no onyomi or kunyomi for kanji: #{kanji}" if onyomi.empty? && kunyomi.empty?

    # Check the important readings.
    important = data["important_reading"]
    die "invalid value (#{important} for 'importent_reading' for kanji: #{kanji}" unless important == "onyomi" || important == "kunyomi"
    message = "important readings for kanji #{kanji} are #{important} but there are none"
    if important == "onyomi"
      die message if onyomi.empty?
    else
      die message if kunyomi.empty?
    end

    # Store the new onyomi readings and their links to the kanji.
    onyomi.each do |on|
      r = Reading.find_or_create_by(kana: on)
      y = Yomi.create(kanji: k, reading: r, on: true, important: important == "onyomi")
    end

    # Store the new kunyomi readings and their links to the kanji.
    kunyomi.each do |kun|
      r = Reading.find_or_create_by(kana: kun)
      y = Yomi.create(kanji: k, reading: r, on: false, important: important == "kunyomi")
    end

    # Update progress.
    progress.increment
  end

  # Feedback about number created.
  puts "new kanji created: #{Kanji.count - kanji_count}"
  puts "new readings created: #{Reading.count - reading_count}"
  puts "new yomi created: #{Yomi.count - yomi_count}"
end

begin
  # Give log messages a bit of context.
  puts Date.today

  # Get a helper object for the tasks we're about to do.
  wk = WaniKani.new(Rails.application.secrets.wani_kani)

  # Update vocabs.
  update_vocabs wk

  # Update kanjis, readings and yomis.
  update_kanjis wk
rescue => e
  # Feedback if there is an error.
  puts "exception: #{e.message}"
end
