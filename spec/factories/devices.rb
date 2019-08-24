FactoryBot.define do
  factory :device do
    notes { [nil, Faker::Lorem.paragraphs(number: 3)].sample }
    name  { Faker::Lorem.words(number: 3).join(" ") }
  end
end
