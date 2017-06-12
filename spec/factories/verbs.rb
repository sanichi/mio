FactoryGirl.define do
  factory :verb do
    category   { Verb::CATEGORIES.sample }
    kanji      { Array.new(3) { "本気赤足首安心入口海王星"[rand(12)] }.join("") }
    meaning    { Faker::Lorem.sentence(3) }
    reading    { Array.new(5) { "あいうえおかきくけこさしすせそ"[rand(15)] }.join("") }
    transitive { [true, false].sample }
  end
end
