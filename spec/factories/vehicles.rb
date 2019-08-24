FactoryBot.define do
  factory :vehicle do
    description  { Faker::Lorem.sentence(word_count: 2).truncate(Vehicle::MAX_DESC).sub(/\A[A-Z]/){ |m| m.downcase } }
    registration { Faker::Number.hexadecimal(digits: Vehicle::MAX_REG).upcase }
    resident
  end
end
