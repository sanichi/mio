require 'wani_kani'

def update_vocabs(wk)
  # Get the kanji of the current vocabs from the DB.
  db_vocabs = Vocab.pluck(:kanji)
  puts "current count of vocabs in #{Rails.env} DB: #{db_vocabs.size}"

  # Get the  user's vocabs from WaniKani.
  wk_vocabs = wk.vocabs
  puts "current count of user vocabulary: #{wk_vocabs.size}"

  # Block any probelmatic kanji (e.g. the sound files returning "access denied").
  # wk_vocabs -= ["取り決め"]

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
  progress = ProgressBar.create(title: "Vocabs", total: new_vocabs.size, output: STDOUT, format: "%t %c |%B|")

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
  progress = ProgressBar.create(title: "Kanji", total: new_kanjis.size, output: STDOUT, format: "%t %c |%B|")

  # Loop over the new kanji.
  new_kanjis.each do |kanji|
    # Get the API data for this kanji.
    data = wk.kanji[kanji]

    # Create a new kanji object.
    k = Kanji.create!(symbol: kanji, meaning: data["meaning"], level: data["level"])

    # Create readings (and yomis, which connect kanjis to their readings and vice-versa).
    error = k.check_reading_data(data["onyomi"], data["kunyomi"], data["important_reading"])
    error = k.create_readings unless error
    die "kanji #{kanji} had a readings error: #{error}" if error

    # Update progress.
    progress.increment
  end

  # Feedback about number created.
  puts "new kanji created: #{Kanji.count - kanji_count}"
  puts "new readings created: #{Reading.count - reading_count}"
  puts "new yomi created: #{Yomi.count - yomi_count}"
end

def update_radicals(wk)
  # Get the symbols of the current radicals from the DB.
  db_radicals = Radical.pluck(:symbol)
  puts "current count of radicals in #{Rails.env} DB: #{db_radicals.size}"

  # Get the  user's radicals from WaniKani.
  wk_radicals = wk.radicals
  puts "current count of user radicals: #{wk_radicals.size}"

  # Block any probelmatic radicals.
  # wk_radicals -= ["半"]

  # Warn about excess radicals.
  excess_radicals = db_radicals - wk_radicals
  puts "excess radicals (#{excess_radicals.size}): #{excess_radicals.join(', ')}" if excess_radicals.any?

  # Get a list of radical we don't have yet.
  new_radicals = wk_radicals - db_radicals
  puts "new radicals to retreive: #{new_radicals.size}"
  return unless new_radicals.any?

  # Note the number of radicals now.
  radical_count = Radical.count

  # Get a progress bar.
  progress = ProgressBar.create(title: "Radicals", total: new_radicals.size, output: STDOUT, format: "%t %c |%B|")

  # Loop over the new radicals.
  new_radicals.each do |radical|
    # Get the API data for this radical.
    data = wk.radical[radical]

    # Is there a matching kanji?
    kanji = Kanji.find_by(symbol: radical)

    # Store all the new data in the DB.
    Radical.create!(symbol: radical, level: data["level"], meaning: data["meaning"], kanji: kanji)

    # Update progress.
    progress.increment
  end

  # Feedback about number created.
  puts "new radicals created: #{Radical.count - radical_count}"
end

begin
  # Give log messages a bit of context.
  puts Date.today

  # Get a helper object for the tasks we're about to do.
  wk = WaniKani.new(Rails.application.credentials.wani_kani)

  # Update vocabs.
  # update_vocabs(wk)

  # Update kanjis, readings and yomis.
  update_kanjis(wk)

  # Update radicals.
  # update_radicals(wk)
rescue => e
  # Feedback if there is an error.
  puts "exception: #{e.message}\n#{e.backtrace.join("\n")}"
end
