FactoryGirl.define do
  factory :device do
    notes        { [nil, Faker::Lorem.paragraph(3)].sample }
    manufacturer { [nil, Faker::Company.name].sample }
    network_name { Faker::Lorem.words(3) }
    real_name    { [nil, Faker::Lorem.words(3)].sample }
  end
end
