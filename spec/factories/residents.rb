FactoryGirl.define do
  factory :resident do
    first_names { (rand(3) + 1).times.map{ Faker::Name.first_name }.join(" ") }
    last_name   { Faker::Name.last_name }
    email       { [nil, Faker::Internet.email].sample }
  end
end
