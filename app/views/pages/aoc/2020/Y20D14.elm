module Y20D14 exposing (answer)


answer : Int -> String -> String
answer part input =
    if part == 1 then
        "10050490168421"

    else
        "2173858456958"



-- quick and dirty Ruby program since once again we are dealing with large integers
--
-- example1 = <<-EXAMPLE1
-- mask = XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X
-- mem[8] = 11
-- mem[7] = 101
-- mem[8] = 0
-- EXAMPLE1
--
-- example2 = <<EXAMPLE2
-- mask = 000000000000000000000000000000X1001X
-- mem[42] = 100
-- mask = 00000000000000000000000000000000X0XX
-- mem[26] = 1
-- EXAMPLE2
--
-- mask = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
--
-- def insert(s, m)
--   n = s.to_i
--   p = 1
--   m.each_char do |c|
--     n = n | p if c == '1'
--     n = n & ~p if c == '0'
--     p *= 2
--   end
--   n
-- end
--
-- def addr(s, m)
--   n = s.to_i
--   p = 1
--   adrs = [n]
--   m.each_char do |c|
--     if c == '1'
--       adrs.map! { |a| a | p }
--     elsif c == 'X'
--       adrs = adrs.map{ |a| [a | p, a & ~p] }.flatten
--     end
--     p *= 2
--   end
--   adrs
-- end
--
-- data = DATA.to_a
--
-- reg = {}
-- data.each do |line|
--   if line =~ /mask = ([01X]{36})/
--     mask = $1.reverse
--   elsif line =~ /mem\[(\d+)\] = (\d+)/
--     reg[$1] = insert($2, mask)
--   else
--     raise "oops #{line}"
--   end
-- end
-- puts reg.values.inject(:+)
--
-- reg = {}
-- data.each do |line|
--   if line =~ /mask = ([01X]{36})/
--     mask = $1.reverse
--   elsif line =~ /mem\[(\d+)\] = (\d+)/
--     num = $2.to_i
--     addr($1, mask).each { |i| reg[i] = num }
--   else
--     raise "oops #{line}"
--   end
-- end
-- puts reg.values.inject(:+)
--
-- __END__
-- (insert data here)
