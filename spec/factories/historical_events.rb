FactoryBot.define do
  factory :historical_event do
    description { "World War 2" }
    finish      { 1945 }
    start       { 1939 }
  end
end
