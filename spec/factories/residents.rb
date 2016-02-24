FactoryGirl.define do
  factory :resident do
    first_names { (rand(3) + 1).times.map{ Faker::Name.first_name }.join(" ") }
    last_name   { Faker::Name.last_name }
    email       { [nil, Faker::Internet.email].sample }
    block       { Resident::MIN_BLOCK + rand(Resident::MAX_BLOCK - Resident::MIN_BLOCK) }
    flat        { Resident::MIN_FLAT + rand(Resident::MAX_FLAT - Resident::MIN_FLAT) }
    bay         { [0, Resident::MIN_BAY + rand(Resident::MAX_BAY - Resident::MIN_BAY)].sample }
  end
end
