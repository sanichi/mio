namespace :kanji do
  desc "convert a kanji into a specially formated list item"
  task :item, [:char] => [:environment] do |t, args|
    if (char = args[:char]).blank?
      puts "please supply a kanji argument (in square braces)"
    else
      kanji = Kanji.includes(:yomis).find_by(symbol: char)
      if kanji.blank?
        puts "no match with '#{char}' found"
      else
        kun = kanji.kun_yomi_kana.join(",")
        on  = kanji.on_yomi_kana.join(",")
        item = "* **#{kanji.symbol}** (#{on};#{kun}) #{kanji.meaning}"
        puts item
        %x{echo '#{item.gsub("'", %Q('"'"'))}' | pbcopy} if Rails.env == "development"
      end
    end
  end
end
