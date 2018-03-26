namespace :vocab do
  desc "convert a vocab item into a specially formated list item"
  task :item, [:word,:indents] => [:environment] do |t, args|
    if (word = args[:word]).blank?
      puts "please supply a word argument (in square braces)"
    else
      indent = "    " * args[:indents].to_i
      vocab = Vocab.find_by(kanji: word)
      if vocab.blank?
        puts "no match with '#{word}' found"
      else
        item = "#{indent}* **#{vocab.kanji}** (#{vocab.reading}) #{vocab.meaning} (#{vocab.category})"
        puts item
        %x{echo '#{item.gsub("'", %Q('"'"'))}' | pbcopy} if Rails.env == "development"
      end
    end
  end
end
