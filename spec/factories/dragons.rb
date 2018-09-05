FactoryBot.define do
  factory :dragon do
    first_name { Faker::Name.first_name }
    last_name  { Faker::Name.last_name }
    male       { [true, false].sample }
  end
end
