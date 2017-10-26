FactoryBot.define do
  factory :resident do
    address     { [nil, [Faker::Address.street_address, Faker::Address.city].join(", ")].sample }
    agent       { [nil, [Faker::Name.first_name, Faker::Name.last_name].join(" ")].sample }
    email       { [nil, Faker::Internet.email].sample }
    first_names { (rand(3) + 1).times.map{ Faker::Name.first_name }.join(" ") }
    last_name   { Faker::Name.last_name }
  end
end
