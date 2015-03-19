FactoryGirl.define do
  factory :income do
    description "Government Pension"
    category    "mark"
    period      "week"
    amount      127.0
    start       Date.new(2020, 11, 9)
    finish      nil
  end
end
