FactoryGirl.define do
  factory :person do
    born         { (1927..1955).to_a.sample }
    born_guess   { [true, false].sample }
    died         nil
    died_guess   false
    first_names  { (rand(3) + 1).times.map{ Faker::Name.first_name }.join(" ") }
    male         { [true, false].sample }
    known_as     { Faker::Name.first_name }
    last_name    { Faker::Name.last_name }
    married_name { !male && [true, false].sample ? Faker::Name.last_name : nil }
    notes        { Faker::Lorem.paragraph(2) }
  end
end
