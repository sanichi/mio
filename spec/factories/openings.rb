FactoryGirl.define do
  factory :opening do
    code        { [%w/A B C D E/.sample, rand(10), rand(10)].join("") }
    description { Faker::Lorem.words(3).join(" ") }
  end
end
