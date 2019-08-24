FactoryBot.define do
  factory :comment do
    source { Faker::Name.name.truncate(Comment::MAX_SOURCE) }
    date   { Faker::Date.backward(days: 365) }
    text   { Faker::Lorem.paragraphs(number: 2) }
  end
end
