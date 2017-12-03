FactoryBot.define do
  factory :kanji_test do
    level { rand(Vocab::MAX_LEVEL) + 1 }
  end
end
