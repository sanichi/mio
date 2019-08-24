FactoryBot.define do
  factory :trade do
    stock                  { Faker::Company.name.truncate(Trade::MAX_STOCK) }
    units                  { Faker::Number.decimal(l_digits: 3, r_digits: 2) }
    buy_date               { Faker::Date.between(from: 200.days.ago, to: 101.days.ago) }
    buy_factor             { 1.0 }
    buy_price              { Faker::Number.decimal(l_digits: 2, r_digits: 2) }
    sell_date              { Faker::Date.between(from: 100.days.ago, to: Date.today) }
    sell_factor            { 1.0 }
    sell_price             { Faker::Number.decimal(l_digits: 2, r_digits: 2) }
  end
end
