FactoryBot.define do
  factory :grammar do
    note   { Faker::Lorem.paragraphs(number: 3) }
    regexp { Faker::Lorem.word.truncate(Grammar::MAX_REGEXP) }
    title  { Faker::Lorem.paragraph.truncate(Grammar::MAX_TITLE) }
  end
end
