FactoryGirl.define do
  factory :return do
    year    { Date.today.year }
    percent 5.5
  end
end
