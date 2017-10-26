FactoryBot.define do
  factory :device do
    notes { [nil, Faker::Lorem.paragraph(3)].sample }
    name  { Faker::Lorem.words(3).join(" ") }
  end
end
