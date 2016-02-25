FactoryGirl.define do
  factory :bay do
    sequence(:number) { |n| n }
    resident
  end
end
