FactoryBot.define do
  factory :star do
    alpha         { "%02d%02d%02d" % [rand(24), rand(60), rand(60)] }
    bayer         { Star::GREEK.values.sample + ["", (1..10).to_a.sample.to_s].sample }
    components    { rand(9) + 1 }
    constellation
    delta         { "%s%02d%02d%02d" % [['', '-'].sample, rand(90), rand(60), rand(60)] }
    distance      { rand(1000) + 1 }
    magnitude     { (7 * rand - 1).round(2) }
    mass          { (1000 * rand - 0.5).round(2) }
    name          { Faker::Name.first_name }
    note          { Faker::Lorem.paragraphs(number: 2) }
    radius        { (1000 * rand - 0.5).round(2) }
    wikipedia     { [nil, CGI.escape(Faker::Name.first_name.gsub(" ", "_"))].sample }
  end
end
