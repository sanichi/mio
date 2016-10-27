FactoryGirl.define do
  factory :trade do
    stock                  { Faker::Company.name.truncate(Trade::MAX_STOCK) }
    units                  { Faker::Number.decimal(3,2) }
    buy_date               { Faker::Date.between(200.days.ago, 101.days.ago) }
    sell_date              { Faker::Date.between(100.days.ago, Date.today) }
    buy_price              { Faker::Number.decimal(2,2) }
    sell_price             { Faker::Number.decimal(2,2) }
  end
end
