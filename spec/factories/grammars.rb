FactoryBot.define do
  factory :grammar do
    eregexp { [Faker::Lorem.word.truncate(Grammar::MAX_REGEXP), nil].sample }
    jregexp { [Faker::Lorem.word.truncate(Grammar::MAX_REGEXP), nil].sample }
    note    { Faker::Lorem.paragraphs(number: 3) }
    title   { Faker::Lorem.paragraph.truncate(Grammar::MAX_TITLE) }
  end
end
