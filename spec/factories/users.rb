FactoryBot.define do
  factory :user do
    email      { Faker::Internet.email }
    password   { Faker::Internet.password(min_length: 6, max_length: 12) }
    person_id  { nil }
    role       { User::ROLES.sample }
    first_name { Faker::Name.first_name }
    last_name  { Faker::Name.last_name }
  end
end
