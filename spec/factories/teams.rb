FactoryBot.define do
  factory :team do
    name     { Faker::Lorem.words(number: rand(4) + 1).map(&:capitalize).join(' ').truncate(Team::MAX_NAME, omission: '', separator: ' ') }
    short    { name.truncate(Team::MAX_SHORT, omission: '', separator: ' ') }
  end
end
