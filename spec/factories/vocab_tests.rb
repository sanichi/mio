FactoryGirl.define do
  factory :vocab_test do
    category  { VocabTest::CATEGORIES.sample }
    complete  0
    level     { rand(Vocab::MAX_LEVEL) + 1 }
  end
end
