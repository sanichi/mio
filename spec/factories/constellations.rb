FactoryBot.define do
  factory :constellation do
    name          { Faker::Name.first_name }
    iau           { ("A".."Z").to_a.sample + ("a".."z").to_a.sample + ("a".."z").to_a.sample }
    note          { Faker::Lorem.paragraphs(number: 2) }
  end
end
