FactoryGirl.define do
  factory :tapa do
    keywords           { Faker::Book.title.truncate(Tapa::MAX_KEYWORDS) }
    sequence(:number)  { |n| n }
    sequence(:post_id) { |p| p }
    title              { Faker::Book.title.truncate(Tapa::MAX_TITLE) }
    notes              { Faker::Lorem.paragraph(2) }
  end
end
