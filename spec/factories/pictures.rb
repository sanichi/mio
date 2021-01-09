FactoryBot.define do
  factory :picture do
    description         { Faker::Lorem.paragraphs(number: 2) }
    people              { Array.new }
    portrait            { [true, false].sample }
    realm               { Person::MIN_REALM.upto(Person::MAX_REALM).to_a.sample }
    sequence(:image, 1) { |n| "#{n}.#{['jpg','png','gif'].sample}" }
  end
end
