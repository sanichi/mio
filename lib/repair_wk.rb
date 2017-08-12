require 'wani_kani'

def repair_vocabs(wk)
  # Get the kanji of the current vocabs from the DB.
  db_vocabs = Vocab.pluck(:kanji)
  puts "current count of vocabs in #{Rails.env} DB: #{db_vocabs.size}"

  # Get the  user's vocabs from WaniKani.
  wk_vocabs = wk.vocabs
  puts "current count of user vocabulary: #{wk_vocabs.size}"

  # Warn about excess vocabs.
  excess_vocabs = db_vocabs - wk_vocabs
  puts "excess vocabs (#{excess_vocabs.size}): #{excess_vocabs.join(', ')}" if excess_vocabs.any?

  # We only want to work with vocabs that are in both sets.
  vocabs = db_vocabs - excess_vocabs
  puts "common vocabs: #{vocabs.size}"

  # Go through each one checking the information is identical.
  todo = 0
  done = 0
  vocabs.each_with_index do |kanji, i|
    # Get the API data for this vocab.
    data = wk.vocab[kanji]

    # Get the database object.
    vocab = Vocab.find_by(kanji: kanji)

    # Prepare the headline if we need it.
    headline = "#{kanji} (#{i+1} of #{vocabs.size})"

    # See if everything is the same.
    if vocab.level != data["level"]
      puts headline unless vocab.changed?
      puts "  level........ #{vocab.level} => #{data["level"]}"
      vocab.level = data["level"]
    end
    if vocab.reading != data["kana"]
      puts headline unless vocab.changed?
      puts "  reading...... #{vocab.reading} => #{data["kana"]}"
      vocab.reading = data["kana"]
    end
    if vocab.meaning != data["meaning"].truncate(Vocab::MAX_MEANING)
      puts headline unless vocab.changed?
      puts "  meaning...... #{vocab.meaning} => #{data["meaning"]}"
      vocab.meaning = data["meaning"]
    end

    # To save time, at the cost of not catching all changes, only scrape data
    # that isn't returned by the API for vocabs that have some other change.
    if vocab.changed?
      # Get the additional data which is only available by scrapeing.
      audio, category = wk.scrape(kanji)

      # Now test this data too.
      if vocab.audio != audio
        puts "  audio........ #{vocab.audio} => #{audio}"
        vocab.audio = audio
      end
      if vocab.category != category.truncate(Vocab::MAX_CATEGORY)
        puts "  category..... #{vocab.category} => #{category}"
        vocab.category = category
      end

      # Increment the number of potential repairs.
      todo += 1

      # Do we want to save the changes?
      if permission_granted?
        vocab.save!
        done += 1
      end
    end
  end

  # Feedback.
  todo = "No" if todo == 0
  done = "none" if done == 0
  puts "#{todo} potential repairs found, #{done} carried out"
end

# def update_kanjis(wk)
#   # Get the symbols of the current kanji from the DB.
#   db_kanjis = Kanji.pluck(:symbol)
#   puts "current count of kanji in #{Rails.env} DB: #{db_kanjis.size}"
#
#   # Get the user's kanji from WaniKani.
#   wk_kanjis = wk.kanjis
#   puts "current count of user kanji: #{wk_kanjis.size}"
#
#   # Warn about excess kanji.
#   excess_kanjis = db_kanjis - wk_kanjis
#   puts "excess kanji (#{excess_kanjis.size}): #{excess_kanjis.join(', ')}" if excess_kanjis.any?
#
#   # Get a list of kanji we don't have yet.
#   new_kanjis = wk_kanjis - db_kanjis
#   puts "new kanji to retreive: #{new_kanjis.size}"
#   return unless new_kanjis.any?
#
#   # Note the number of releavant objects now.
#   kanji_count = Kanji.count
#   reading_count = Reading.count
#   yomi_count = Yomi.count
#
#   # Get a progress bar.
#   progress = ProgressBar.create(title: "Kanji", total: new_kanjis.size, output: STDOUT, format: "%t %c |%B|")
#
#   # Loop over the new kanji.
#   new_kanjis.each do |kanji|
#     # Get the API data for this kanji.
#     data = wk.kanji[kanji]
#
#     # Create a new kanji object.
#     k = Kanji.create!(symbol: kanji, meaning: data["meaning"], level: data["level"])
#
#     # Organise the WaniKani reading data.
#     onyomi = data["onyomi"].to_s.gsub(/[\sa-zA-Z\/.*]/, "").split(",")
#     kunyomi = data["kunyomi"].to_s.gsub(/[\sa-zA-Z\/.*]/, "").split(",")
#     die "no onyomi or kunyomi for kanji: #{kanji}" if onyomi.empty? && kunyomi.empty?
#
#     # Check the important readings.
#     important = data["important_reading"]
#     die "invalid value (#{important} for 'importent_reading' for kanji: #{kanji}" unless important == "onyomi" || important == "kunyomi"
#     message = "important readings for kanji #{kanji} are #{important} but there are none"
#     if important == "onyomi"
#       die message if onyomi.empty?
#     else
#       die message if kunyomi.empty?
#     end
#
#     # Store the new onyomi readings and their links to the kanji.
#     onyomi.each do |on|
#       r = Reading.find_or_create_by!(kana: on)
#       y = Yomi.create!(kanji: k, reading: r, on: true, important: important == "onyomi")
#     end
#
#     # Store the new kunyomi readings and their links to the kanji.
#     kunyomi.each do |kun|
#       r = Reading.find_or_create_by!(kana: kun)
#       y = Yomi.create!(kanji: k, reading: r, on: false, important: important == "kunyomi")
#     end
#
#     # Update progress.
#     progress.increment
#   end

#   # Feedback about number created.
#   puts "new kanji created: #{Kanji.count - kanji_count}"
#   puts "new readings created: #{Reading.count - reading_count}"
#   puts "new yomi created: #{Yomi.count - yomi_count}"
# end

def permission_granted?(count=1)
  print "  update [Ynq]? "
  case gets.chomp
  when "", /\Ay(es)?\z/i
    true
  when /\Ano?\z/i
    false
  when /\A(q(uit)?|e?x(it)?)\z/i
    puts "user chose to exit"
    exit
  else
    if count < 3
      permission_granted?(count + 1)
    else
      raise("too many invalid responses")
    end
  end
end

begin
  # Give log messages a bit of context.
  puts Date.today

  # Get a helper object for the tasks we're about to do.
  wk = WaniKani.new(Rails.application.secrets.wani_kani)

  # Repair vocabs.
  repair_vocabs(wk)

  # Update kanjis, readings and yomis.
  # repair_kanjis(wk)
rescue => e
  # Feedback if there is an error.
  puts "exception: #{e.message}"
end
