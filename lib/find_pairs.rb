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

# the string representation for a pair
def srep(t, i)
  "#{t} => #{i}"
end

# create a list of pairs we don't want to include (ones that the method here is otherwise too simplistic to exclude)
xa = [
  ["出す", "出かける"],
  ["見せる", "見える"],
  ["足す", "足りない"],
  ["行う", "行く"],
  ["生む", "生える"],
  ["生む", "生きる"],
  ["交ぜる", "交わる"],
  ["上げる", "上る"],
  ["乗せる", "乗る"],
  ["通す", "通う"],
  ["放つ", "放れる"],
  ["起こす", "起こる"],
  ["混ぜる", "混じる"],
  ["混ぜる", "混む"],
]

# from this create an exclusion hash keyed on the string representations for pairs
xh = xa.each_with_object({}) { |a, h| h[srep(a[0], a[1])] = true; h }


# create a single hash where:
#   keys: pairs of vocab IDs (later used to eliminate duplicates)
#   vals: string representation (to be printed later) of a transitive-intransitive pair
# avoid adding any from the excusion hash
hp = ht.keys.each_with_object({}) do |k, h|
  if hi[k]
    vt = ht[k]
    vi = hi[k]
    vt.each do |t|
      vi.each do |i|
        rep = srep(t.kanji, i.kanji)
        h["#{t.id}_#{i.id}"] = rep unless xh[rep]
      end
    end
  end
  h
end
puts "total pairs found: #{hp.size}"

# to start the process of de-duplication, get the existing pairs
ps = VerbPair.all
puts "existing verb pairs: #{ps.count}"

# delete pairs from the search hash that we already have
ps.each { |p| hp.delete("#{p.transitive_id}_#{p.intransitive_id}") }
puts "verb pairs after de-duplication: #{hp.count}"

# finally, list all the new verb pairs
hp.values.each { |p| puts p }
