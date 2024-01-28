FactoryBot.define do
  factory :constellation do
    iau           { ("A".."Z").to_a.sample + ("a".."z").to_a.sample + ("a".."z").to_a.sample }
    name          { Faker::Name.first_name }
    note          { Faker::Lorem.paragraphs(number: 2) }
    wikipedia     { [nil, CGI.escape(Faker::Name.first_name.gsub(" ", "_"))].sample }
  end
end
