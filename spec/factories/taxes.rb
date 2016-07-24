FactoryGirl.define do
  factory :tax do
    description { Faker::Book.title.truncate(Tax::MAX_DESC) }
    free        { rand(25) }
    income      { 100 + rand(1000) }
    paid        { (income * rand(1) * 0.2).round }
    year_number { rand(Tax.current_year_number + 1) }
  end
end
