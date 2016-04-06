FactoryGirl.define do
  factory :flat do
    sequence(:building) { |i| Flat::BUILDINGS[i % (Flat::BUILDINGS.size - 1)] }
    sequence(:number)   { |i| Flat::NUMBERS[i % (Flat::NUMBERS.size - 1)] }
    sequence(:block)    { |i| Flat::BLOCKS[i % (Flat::BLOCKS.size - 1)] }
    sequence(:bay)      { |i| Flat::BAYS[i % (Flat::BAYS.size - 1)] }
    category            { Flat::CATEGORIES.sample }
    name                { Flat::NAMES.sample }
    notes               { Faker::Lorem.paragraph(2) }
  end
end
