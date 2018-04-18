require 'wani_kani'

def repair_vocabs(wk)
  # Get the kanji of the current vocabs from the DB.
  db_vocabs = Vocab.pluck(:kanji)
  puts "current count of vocabs in #{Rails.env} DB: #{db_vocabs.size}"

  # Get the user's vocabs from WaniKani.
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
  todo = "no" if todo == 0
  done = "none" if done == 0
  puts "#{todo} potential repairs found, #{done} carried out"
end

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
  wk = WaniKani.new(Rails.application.credentials.wani_kani)

  # Repair vocabs.
  repair_vocabs(wk)
rescue => e
  # Feedback if there is an error.
  puts "exception: #{e.message}"
  puts e.backtrace
end
