FactoryBot.define do
  factory :picture do
    description { Faker::Lorem.paragraph(2) }
    people      { Array.new }
    portrait    { [true, false].sample }
  end
end
