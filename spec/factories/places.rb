FactoryBot.define do
  factory :place do
    jname    { Faker::Lorem.characters(number: 10) }
    ename    { Faker::Lorem.characters(number: 10) }
    reading  { Faker::Lorem.characters(number: 10) }
    wiki     { Faker::Lorem.characters(number: 10) }
    category { Place::CATS.keys.sample }
    capital  { category == "city" ? [true, false].sample : false }
    pop      { category == "attraction" ? 0 : 1 + rand(1000) }
    vbox     { ["#{rand(750) - 100} #{rand(750) + 300} #{rand(750) + 1} #{rand(750) + 1}", nil].sample}
    notes    { Faker::Lorem.paragraphs(number: 3) }
  end
end
