FactoryGirl.define do
  factory :todo do
    description  { Faker::Lorem.paragraph.truncate(Todo::MAX_DESC) }
    priority     { Todo::PRIORITIES.sample }
    done         { [true, false].sample }
  end
end
