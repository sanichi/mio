FactoryBot.define do
  factory :similar_kanji do
    kanjis { %w/上 下	人	九 力 入 女 八 一 二 三 山 工 口/.sample(2+rand(4)).join('') }
  end
end
