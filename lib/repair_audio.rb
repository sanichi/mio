require 'wani_kani'

# Redownloads any audio files that for some reason are not there on disk.
# Note: after the change in audi-file names in late 2017, e.g.
#
#   old: https://cdn.wanikani.com/audio/cd02120980f6db548a44814113e5224ef70c5755.mp3
#   new: https://cdn.wanikani.com/subjects/audio/7517-%E4%BA%BA%E3%80%85.mp3
#
# this script will no longer works for records still using the old format.
# To make it work again would require converting all old style records to
# new and that would require more scraping.

begin
  raise "no longer working after WK change to audio file format"

  # Get the audio references of the current vocabs from the DB.
  db_audio = Vocab.pluck(:audio)
  puts "audio references in #{Rails.env} DB: #{db_audio.size}"

  # Get a WaniKani object.
  wk = WaniKani.new(Rails.application.secrets.wani_kani)

  # Find which of these have not been downloaded yet.
  new_audio = db_audio.reject { |f| wk.audio_exist?(f) }
  puts "audio files to download: #{new_audio.size}"
  exit(true) unless new_audio.any?

  # Loop over the audio files to download.
  count = 0
  new_audio.each do |file|
    wk.download_audio(file)
    count += 1
  end

  # Feedback about number downloaded.
  puts "audio files downloaded: #{count}"
rescue => e
  # Feedback if there is an error.
  puts "exception: #{e.message}"
end
