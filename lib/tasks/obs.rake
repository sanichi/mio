# This was useful for understanding rake a bit more than I used to:
# https://stackoverflow.com/questions/825748/how-to-pass-command-line-arguments-to-a-rake-task
namespace :obs do
  # example: bin/rails obs:kanji\[鋭,T\]
  desc "create or overwrite a kanji note for obsidian"
  task :kanji, [:char, :nuke] => :environment do |task, args|
    check_env!
    args.with_defaults(:char => "ABSENT", :nuke => "true")
    char = args[:char]
    nuke = args[:nuke].match?(/\At(rue)?|y(es)?\z/i)
    report("please supply a Kanji character", true) if char == "ABSENT"
    report("please supply a single character", true) unless char.length == 1
    kanji = Wk::Kanji.find_by(character: char) or report("cannot find kanji character #{char}", true)
    report "char #{char}"
    report "nuke #{nuke}"
  end

  def check_env!
    return if Rails.env.development?
    report("this task is not for the #{Rails.env} environment", true)
  end

  def report(msg, error=false)
    if error
      puts "ERROR: #{msg}"
      exit 1
    else
      puts msg
    end
  end
end
