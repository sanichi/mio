require 'wani_kani'

def repair(wk)
  # Get the symbol of the current radicals from the DB.
  db_radicals = Radical.pluck(:symbol)
  puts "current count of radicals in #{Rails.env} DB: #{db_radicals.size}"

  # Get the user's radicals from WaniKani.
  wk_radicals = wk.radicals
  puts "current count of user radicals: #{wk_radicals.size}"

  # Warn about excess radicals.
  excess_radicals = db_radicals - wk_radicals
  puts "excess radicals (#{excess_radicals.size}): #{excess_radicals.join(', ')}" if excess_radicals.any?

  # We only want to work with radicals that are in both sets.
  radicals = db_radicals - excess_radicals
  puts "common radicals: #{radicals.size}"

  # Go through each one checking the information is identical.
  todo = 0
  done = 0
  radicals.each_with_index do |symbol, i|
    # Get the API data for this radical.
    data = wk.radical[symbol]

    # Get the database object.
    radical = Radical.find_by(symbol: symbol)

    # Prepare the headline if we need it.
    headline = "#{symbol} (#{i+1} of #{radicals.size})"

    # See if everything is the same.
    if data["level"].is_a?(Integer) && radical.level != data["level"]
      puts headline unless radical.changed?
      puts "  level........ #{radical.level} => #{data["level"]}"
      radical.level = data["level"]
    end
    if data["meaning"].is_a?(String) && radical.meaning != data["meaning"].truncate(Radical::MAX_MEANING)
      puts headline unless radical.changed?
      puts "  meaning...... #{radical.meaning} => #{data["meaning"]}"
      radical.meaning = data["meaning"]
    end
    if data["user_specific"].is_a?(Hash) && [true, false].include?(data["user_specific"]["burned"]) && radical.burned != data["user_specific"]["burned"]
      puts headline unless radical.changed?
      puts "  burned....... #{radical.burned} => #{data["user_specific"]["burned"]}"
      radical.burned = data["user_specific"]["burned"]
    end

    # To save time, at the cost of not catching all changes, only scrape data
    # that isn't returned by the API for radicals that have some other change.
    if radical.changed?
      # Increment the number of potential repairs.
      todo += 1

      # Do we want to save the changes?
      if wk.permission_granted?
        radical.save!
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

  # Repair radicals.
  repair(wk)
rescue => e
  # Feedback if there is an error.
  puts "exception: #{e.message}"
  puts e.backtrace
end
