FactoryBot.define do
  factory :problem do
    level       { rand(Problem::MAX_LEVEL + 1) }
    category    { rand(Problem::MAX_CATEGORY + 1) }
    subcategory { rand(Problem::MAX_SUBCATEGORY + 1) }
    note        { Faker::Lorem.paragraphs(number: 3) }
  end
end
