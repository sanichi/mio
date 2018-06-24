FactoryBot.define do
  factory :vocab do
    accent   { reading.nil?? nil : 0.upto(Vocab.mora(reading)).to_a.sample }
    audio    { Array.new(40) { "abcdef0123456789"[rand(16)] }.join("") + ".mp3" }
    category { %w/noun verb adjective/.sample }
    level    { rand(60) + 1 }
    kanji    { Array.new(3) { "本気赤足首安心入口海王星"[rand(12)] }.join("") }
    meaning  { Faker::Lorem.sentence(3) }
    reading  { Array.new(5) { "あいうえおかきくけこさしすせそ"[rand(15)] }.join("") }
  end
end
