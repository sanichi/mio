FactoryBot.define do
  factory :user do
    email     { Faker::Internet.email }
    password  { Faker::Internet.password(min_length: 6, max_length: 12) }
    person_id { nil }
    role      { User::ROLES.sample }
  end
end
