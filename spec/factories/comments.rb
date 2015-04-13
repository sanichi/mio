FactoryGirl.define do
  factory :comment do
    source { Faker::Name.name.truncate(Comment::MAX_SOURCE) }
    date   { Faker::Date.backward(365) }
    text   { Faker::Lorem.paragraph(2) }
  end
end
