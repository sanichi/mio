FactoryBot.define do
  factory :picture do
    description { Faker::Lorem.paragraphs(number: 2) }
    people      { Array.new }
    portrait    { [true, false].sample }
    realm       { Person::MIN_REALM.upto(Person::MAX_REALM).to_a.sample }
  end
end
