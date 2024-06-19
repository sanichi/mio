# This was useful for understanding rake a bit more than I used to:
# https://stackoverflow.com/questions/825748/how-to-pass-command-line-arguments-to-a-rake-task
namespace :obs do
  desc "create or update kanji notes for obsidian"
  task :kanji, [:chrs, :nuke] => :environment do |task, args|
    check!
    args.with_defaults(:chrs => "", :nuke => "true")
    nuke = args[:nuke].match?(/\At(rue)?|y(es)?\z/i)
    chrs = args[:chrs].scan(/[\p{Han}]/)
    report("please supply some kanji, e.g. bin/rails obs:kanji\\[新鋭,T\\]", true) unless chrs.size > 0
    kanji = chrs.map do |chr|
      Wk::Kanji.find_by(character: chr) or report("cannot find kanji #{chr}", true)
    end
    report "kanji: #{kanji.map(&:character).join(',')}"
    report "nuke:  #{nuke}"
  end

  def check!
    report("this task is not for the #{Rails.env} environment", true) unless Rails.env.development?
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
