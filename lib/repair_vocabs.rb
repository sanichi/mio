require 'wani_kani'

begin
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
