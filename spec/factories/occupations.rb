FactoryBot.define do
  factory :occupation do
    kanji    { Array.new(3) { "本気赤足首安心入口海王星"[rand(12)] }.join("") }
    meaning  { Faker::Lorem.sentence(3) }
    reading  { Array.new(5) { "あいうえおかきくけこさしすせそ"[rand(15)] }.join("") }
  end
end
