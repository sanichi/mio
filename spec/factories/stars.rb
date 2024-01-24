FactoryBot.define do
  factory :star do
    distance { rand(1000) + 1 }
    name     { Faker::Name.first_name }
    note     { Faker::Lorem.paragraphs(number: 2) }
    alpha    { "%02d%02d%02d" % [rand(24), rand(60), rand(60)] }
    delta    { "%s%02d%02d%02d" % [['', '-'].sample, rand(90), rand(60), rand(60)] }
  end
end
