FactoryBot.define do
  factory :user do
    email     { Faker::Internet.email }
    password  { Faker::Internet.password(6, 12) }
    person_id { nil }
    role      { User::ROLES.sample }
  end
end
