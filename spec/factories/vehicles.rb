FactoryBot.define do
  factory :vehicle do
    description  { Faker::Lorem.sentence(2).truncate(Vehicle::MAX_DESC).sub(/\A[A-Z]/){ |m| m.downcase } }
    registration { Faker::Number.hexadecimal(Vehicle::MAX_REG).upcase }
    resident
  end
end
