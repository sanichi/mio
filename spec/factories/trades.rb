FactoryGirl.define do
  factory :trade do
    stock                  { Faker::Company.name.truncate(Trade::MAX_STOCK) }
    units                  { Faker::Number.decimal(3,2) }
    buy_date               { Faker::Date.between(200.days.ago, 101.days.ago) }
    buy_factor             1.0
    buy_price              { Faker::Number.decimal(2,2) }
    sell_date              { Faker::Date.between(100.days.ago, Date.today) }
    sell_factor            1.0
    sell_price             { Faker::Number.decimal(2,2) }
  end
end
