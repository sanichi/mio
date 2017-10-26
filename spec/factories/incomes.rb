FactoryBot.define do
  factory :income do
    amount      127.0
    category    "mark"
    description "Government Pension"
    finish      nil
    joint       50
    period      "week"
    start       Date.new(2020, 11, 9)
  end
end
