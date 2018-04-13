WS = "[\s\t\u3000]+"

namespace :vocab do
  desc "convert a vocab item into a specially formated list item"
  task :item, [:words,:indents] => [:environment] do |t, args|
    if (words = args[:words]).blank?
      puts "please supply a word(s) argument (in square braces)"
    else
      indent = "    " * args[:indents].to_i
      items = []
      words.sub(/^#{WS}/, "").split(/#{WS}/).each do |word|
        vocab = Vocab.find_by(kanji: word)
        if vocab.blank?
          puts "no match with '#{word}' found"
        else
          item = "#{indent}* **#{vocab.kanji}** (#{vocab.reading}) #{vocab.meaning} (#{vocab.category})"
          puts item
          items.push(item.gsub("'", %Q('"'"')))
        end
      end
      %x{echo '#{items.join("\n")}' | pbcopy} if Rails.env == "development" && !items.empty?
    end
  end
end
