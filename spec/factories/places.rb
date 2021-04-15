FactoryBot.define do
  factory :place do
    jname         { Faker::Lorem.characters(number: 10) }
    ename         { Faker::Lorem.characters(number: 10) }
    reading       { Faker::Lorem.characters(number: 10) }
    wiki          { Faker::Lorem.characters(number: 10) }
    category      { Place::CATS.keys.sample }
    capital       { category == "city" ? [true, false].sample : false }
    pop           { category == "attraction" ? 0 : 1 + rand(1000) }
    vbox          { ["#{rand(Place::W) + Place::X} #{rand(Place::H) + Place::Y} #{rand(Place::W) + 1} #{rand(Place::H) + 1}", nil].sample}
    notes         { Faker::Lorem.paragraphs(number: 3) }
    text_position { [nil, "#{Place::X + rand(Place::W)},#{Place::Y + rand(Place::H)}"].sample }
    mark_position { [nil, "#{Place::X + rand(Place::W)},#{Place::Y + rand(Place::H)}"].sample }
  end
end
