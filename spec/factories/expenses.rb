FactoryBot.define do
  factory :expense do
    description { "Test" }
    category    { "mark" }
    period      { "month" }
    amount      { 22.0 }
  end
end
