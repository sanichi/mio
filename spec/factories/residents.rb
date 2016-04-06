FactoryGirl.define do
  factory :resident do
    address     { [nil, [Faker::Address.street_address, Faker::Address.city].join(", ")].sample }
    first_names { (rand(3) + 1).times.map{ Faker::Name.first_name }.join(" ") }
    last_name   { Faker::Name.last_name }
    email       { [nil, Faker::Internet.email].sample }
  end
end
