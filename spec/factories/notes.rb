FactoryBot.define do
  factory :note do
    stuff                { Faker::Lorem.paragraphs(number: 3) }
    title                { Faker::Lorem.paragraph.truncate(Note::MAX_TITLE) }
    series               { [Faker::Lorem.sentence.truncate(Note::MAX_SERIES), nil].sample }
    sequence(:number, 1) { |n| n }
  end
end
