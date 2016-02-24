FactoryGirl.define do
  factory :vehicle do
    registration { Faker::Number.hexadecimal(7).upcase }
    resident
  end
end
