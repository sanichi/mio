FactoryGirl.define do
  factory :tapa do
    keywords          { Faker::Book.title.truncate(Tapa::MAX_KEYWORDS) }
    sequence(:number) { |n| n }
    title             { Faker::Book.title.truncate(Tapa::MAX_TITLE) }
  end
end
