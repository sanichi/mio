FactoryBot.define do
  factory :star do
    distance { rand(1000) + 1 }
    name     { Faker::Name.first_name }
    note     { Faker::Lorem.paragraphs(number: 2) }
  end
end
