FactoryBot.define do
  factory :subscription do
    payee     { Faker::Company.name.truncate(Subscription::MAX_PAYEE) }
    amount    { 1 + rand(10000) }
    frequency { Subscription.frequencies.keys.sample }
    source    { Faker::Lorem.words(number: rand(3) + 1).join(" ").truncate(Subscription::MAX_SOURCE) }
  end
end