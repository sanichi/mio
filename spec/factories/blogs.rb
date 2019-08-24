FactoryBot.define do
  factory :blog do
    draft { false }
    story { Faker::Lorem.paragraphs(number: 3) }
    title { Faker::Lorem.sentence(word_count: 5).truncate(Blog::MAX_TITLE) }
    user
  end
end
