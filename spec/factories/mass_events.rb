FactoryBot.define do
  factory :mass_event do
    code             { Faker::Lorem.word.truncate(MassEvent::MAX_CODE) }
    name             { Faker::Lorem.word.truncate(MassEvent::MAX_NAME) }
    sequence(:start) { |n| Date.today.ago((300 - 5 * n).days).to_date }
    finish           { start + rand(5) }
  end
end
