FactoryBot.define do
  factory :tutorial do
    date    { Faker::Date.between(from: 2.years.ago, to: Date.today) }
    notes   { Faker::Lorem.paragraphs(number: 3) }
    summary { Faker::Lorem.sentence.truncate(Tutorial::MAX_SUMMARY) }
  end
end
