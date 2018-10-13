# get existing transitive verbs
ts = Vocab.where("category ILIKE '%verb%' AND category NOT ILIKE 'suru' AND category ~* '(^|[^n])transitive' AND category NOT ILIKE '%intransitive%'").all
puts "transitive verbs: #{ts.count}"

# get existing intransitive verbs
is = Vocab.where("category ILIKE '%verb%' AND category NOT ILIKE 'suru' AND category !~* '(^|[^n])transitive' AND category ILIKE '%intransitive%'").all
puts "intransitive verbs: #{is.count}"

# create two hashes, one hash for transitives and one for intransitives, where:
#   keys: sequences of kanji characters (usually just one)
#   vals: one or more (usually just one) verbs containing those characters
ht = Hash.new { |h, k| h[k] = [] }
ht = ts.each_with_object(ht) do |t, h|
  kanji = t.kanji.split("").keep_if { |c| Kanji.find_by(symbol: c) }.join("")
  h[kanji] << t
end
hi = Hash.new { |h, k| h[k] = [] }
hi = is.each_with_object(hi) do |i, h|
  kanji = i.kanji.split("").keep_if { |c| Kanji.find_by(symbol: c) }.join("")
  h[kanji] << i
end

# create a single hash where:
#   keys: pairs of vocab IDs (later used to eliminate duplicates)
#   vals: string representation (to be printed later) of potential transitive-intransitive pair
hp = ht.keys.each_with_object({}) do |k, h|
  if hi[k]
    vt = ht[k]
    vi = hi[k]
    vt.each do |t|
      vi.each do |i|
        h["#{t.id}_#{i.id}"] = "#{t.kanji} => #{i.kanji}"
      end
    end
  end
  h
end
puts "total pairs: #{hp.size}"

# to start the process of de-duplication, get the existing pairs
ps = VerbPair.all
puts "existing verb pairs: #{ps.count}"

# delete pairs from the search hash that we already have
ps.each { |p| hp.delete("#{p.transitive_id}_#{p.intransitive_id}") }
puts "verb pairs after de-duplication: #{hp.count}"

# finally, list all the new verb pairs
hp.values.each { |p| puts p }
