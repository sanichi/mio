FactoryBot.define do
  factory :star do
    alpha         { "%02d%02d%02d" % [rand(24), rand(60), rand(60)] }
    bayer         { Star::GREEK.values.sample + ["", (1..10).to_a.sample.to_s].sample }
    components    { rand(9) + 1 }
    constellation
    delta         { "%s%02d%02d%02d" % [['', '-'].sample, rand(90), rand(60), rand(60)] }
    distance      { rand(1000) + 1 }
    luminosity    { (1000000 * rand - 0.5).round(2) }
    magnitude     { (7 * rand - 1).round(2) }
    mass          { (1000 * rand - 0.5).round(2) }
    name          { Faker::Name.first_name }
    note          { Faker::Lorem.paragraphs(number: 2) }
    radius        { (1000 * rand - 0.5).round(2) }
    rank          { [nil, 1 + rand(100)].sample }
    spectrum      { %w/O B A F G K M/.sample + %w/0 1 2 3 4 5 6 7 8 9/.sample + " " + %w/I II III IV V sd D/.sample }
    temperature   { rand(100000) + 300 }
    wikipedia     { [nil, CGI.escape(Faker::Name.first_name.gsub(" ", "_"))].sample }
  end
end
