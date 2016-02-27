FactoryGirl.define do
  factory :vehicle do
    description  { Faker::Lorem.sentence(2).truncate(Vehicle::MAX_DESC) }
    registration { Faker::Number.hexadecimal(7).upcase }
    resident
  end
end
