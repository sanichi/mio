FactoryBot.define do
  factory :grammar do
    eregexp           { [Faker::Lorem.word.truncate(Grammar::MAX_REGEXP), nil].sample }
    jregexp           { [Faker::Lorem.word.truncate(Grammar::MAX_REGEXP), nil].sample }
    note              { Faker::Lorem.paragraphs(number: 3) }
    sequence(:ref, 1) { |n| Faker::Lorem.characters(number: 3, min_alpha: 3).upcase + n.to_s }
    title             { Faker::Lorem.paragraph.truncate(Grammar::MAX_TITLE) }
  end
end
