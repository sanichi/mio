FactoryBot.define do
  factory :note do
    number { [rand(10), nil].sample }
    series { [Faker::Lorem.sentence.truncate(Note::MAX_SERIES), nil].sample }
    stuff  { Faker::Lorem.paragraphs(number: 3) }
    title  { Faker::Lorem.paragraph.truncate(Note::MAX_TITLE) }
  end
end
