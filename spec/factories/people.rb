FactoryGirl.define do
  factory :person do
    born        { (1927..1955).to_a.sample }
    died        nil
    first_names { (rand(3) + 1).times.map{ Faker::Name.first_name }.join(" ") }
    gender      { [true, false].sample }
    known_as    { Faker::Name.first_name }
    last_name   { Faker::Name.last_name }
    notes       { Faker::Lorem.paragraph(2) }
  end
end
