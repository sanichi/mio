FactoryBot.define do
  factory :vocab_test do
    category      { VocabTest::CATEGORIES.sample }
    level         { rand(Vocab::MAX_LEVEL) + 1 }
  end
end
