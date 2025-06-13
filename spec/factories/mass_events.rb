FactoryBot.define do
  factory :mass_event do
    name             { Faker::Lorem.word.truncate(MassEvent::MAX_NAME) }
    sequence(:start) { |n| Date.today.ago((100 - 10 * n).days).to_date }
    finish           { start + rand(10) }
  end
end
