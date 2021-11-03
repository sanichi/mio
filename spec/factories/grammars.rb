FactoryBot.define do
  factory :grammar do
    eregexp { [Faker::Lorem.word.truncate(Grammar::MAX_REGEXP), nil].sample }
    note    { Faker::Lorem.paragraphs(number: 3) }
    regexp  { [Faker::Lorem.word.truncate(Grammar::MAX_REGEXP), nil].sample }
    title   { Faker::Lorem.paragraph.truncate(Grammar::MAX_TITLE) }
  end
end
