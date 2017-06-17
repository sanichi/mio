require 'wani_kani'

begin
  # Give log messages a bit of context.
  puts Date.today

  # Get the kanji of the current vocabs from the DB.
  db_vocabs = Vocab.pluck(:kanji)
  puts "current count in #{Rails.env} DB: #{db_vocabs.size}"

  # Get the kanji of the current user vocabs from WaniKani.
  wk = WaniKani.new(Rails.application.secrets.wani_kani)
  wk_vocabs = wk.vocabs
  puts "current count of user vocabulary: #{wk_vocabs.size}"

  # Warn about excess vocabs.
  excess_vocabs = db_vocabs - wk_vocabs
  puts "excess vocabs (#{excess_vocabs.size}): #{excess_vocabs.join(', ')}" if excess_vocabs.any?

  # Get a list of vocab we don't have yet.
  new_vocabs = wk_vocabs - db_vocabs
  puts "new vocabulary to retreive: #{new_vocabs.size}"
  exit(true) unless new_vocabs.any?

  # Get a progress bar.
  progress = ProgressBar.create(title: "Vocabs", total: new_vocabs.size, output: STDOUT)

  # Loop over the new kanji.
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
  puts "new vocabs created: #{new_vocabs.size} (from #{new_vocabs.first} to #{new_vocabs.last})"
rescue => e
  # Feedback if there is an error.
  puts "exception: #{e.message}"
end
