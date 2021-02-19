FactoryBot.define do
  factory :place do
    jname    { Faker::Lorem.characters(number: 10) }
    ename    { Faker::Lorem.characters(number: 10) }
    reading  { Faker::Lorem.characters(number: 10) }
    wiki     { Faker::Lorem.characters(number: 10) }
    category { Place::CATS.keys.sample }
    pop      { 1 + rand(1000) }
  end
end
