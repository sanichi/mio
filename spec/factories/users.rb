FactoryGirl.define do
  factory :user do
    email    { Faker::Internet.email }
    password { Faker::Internet.password(6, 12) }
    role     { User::ROLES.sample }
  end
end
