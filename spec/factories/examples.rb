FactoryBot.define do
  factory :wk_example, class: 'Wk::Example' do
    japanese { Faker::Lorem.sentence.truncate(Wk::Example::MAX_EXAMPLE).gsub(" ", "") }
    english  { Faker::Lorem.sentence.truncate(Wk::Example::MAX_EXAMPLE) }
  end
end
