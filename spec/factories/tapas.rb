FactoryGirl.define do
  factory :tapa do
    keywords           { Faker::Book.title.truncate(Tapa::MAX_KEYWORDS) }
    notes              { Faker::Lorem.paragraph(2) }
    sequence(:number)  { |n| n }
    post_id            { "%s/episode-%d-%s/" % [Faker::Date.between(1.year.ago, 1.year.from_now).strftime('%Y/%m/%d'), number, Faker::Lorem.words.join("-")] }
    title              { Faker::Book.title.truncate(Tapa::MAX_TITLE) }
    star               { [true, false].sample }
  end
end
