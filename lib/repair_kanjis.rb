require 'wani_kani'

def repair(wk)
  # Get the symbol of the current kanjis from the DB.
  db_kanjis = Kanji.pluck(:symbol)
  puts "current count of kanjis in #{Rails.env} DB: #{db_kanjis.size}"

  # Get the user's kanjis from WaniKani.
  wk_kanjis = wk.kanjis
  puts "current count of user kanjis: #{wk_kanjis.size}"

  # Warn about excess kanjis.
  excess_kanjis = db_kanjis - wk_kanjis
  puts "excess kanjis (#{excess_kanjis.size}): #{excess_kanjis.join(', ')}" if excess_kanjis.any?

  # We only want to work with kanjis that are in both sets.
  kanjis = db_kanjis - excess_kanjis
  puts "common kanjis: #{kanjis.size}"

  # Go through each one checking the information is identical.
  todo = 0
  done = 0
  kanjis.each_with_index do |symbol, i|
    # Get the API data for this kanji.
    data = wk.kanji[symbol]

    # Get the database object.
    kanji = Kanji.find_by(symbol: symbol)

    # Prepare the headline if we need it.
    headline = "#{symbol} (#{i+1} of #{kanjis.size})"

    # See if everything is the same.
    if data["level"].is_a?(Integer) && kanji.level != data["level"]
      puts headline unless kanji.changed?
      puts "  level........ #{kanji.level} => #{data["level"]}"
      kanji.level = data["level"]
    end
    if data["meaning"].is_a?(String) && kanji.meaning != data["meaning"].truncate(Kanji::MAX_MEANING)
      puts headline unless kanji.changed?
      puts "  meaning...... #{kanji.meaning} => #{data["meaning"]}"
      kanji.meaning = data["meaning"]
    end
    if data["user_specific"].is_a?(Hash) && [true, false].include?(data["user_specific"]["burned"]) && kanji.burned != data["user_specific"]["burned"]
      puts headline unless kanji.changed?
      puts "  burned....... #{kanji.burned} => #{data["user_specific"]["burned"]}"
      kanji.burned = data["user_specific"]["burned"]
    end

    # Check if the readings have changed. This is more involved because of how the data is structured.
    error = kanji.check_reading_data(data["onyomi"], data["kunyomi"], data["important_reading"])
    die "kanji #{symbol} had a readings setup error: #{error}" if error
    readings_change = kanji.readings_change

    if readings_change
      puts headline unless kanji.changed?
      puts "  reading...... #{readings_change}"
    end

    # To save time, at the cost of not catching all changes, only scrape data
    # that isn't returned by the API for kanjis that have some other change.
    if kanji.changed? || readings_change
      # Increment the number of potential repairs.
      todo += 1

      # Do we want to save the changes?
      if wk.permission_granted?
        kanji.save! unless !kanji.changed?
        if readings_change
          error = kanji.create_readings(update: true)
          die "kanji #{symbol} had a readings processing error: #{error}" if error
        end
        done += 1
      end
    end
  end

  # Feedback.
  todo = "no" if todo == 0
  done = "none" if done == 0
  puts "#{todo} potential repairs found, #{done} carried out"
end

begin
  # Give log messages a bit of context.
  puts Date.today

  # Get a helper object for the tasks we're about to do.
  wk = WaniKani.new(Rails.application.credentials.wani_kani)

  # Repair kanjis.
  repair(wk)
rescue => e
  # Feedback if there is an error.
  puts "exception: #{e.message}"
  puts e.backtrace
end
