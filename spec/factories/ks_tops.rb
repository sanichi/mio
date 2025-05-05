FactoryBot.define do
  factory :ks_top, class: Ks::Top do
    association :journal, factory: :ks_journal
    measured_at { Faker::Time.backward(days: 1).utc.strftime("%Y-%m-%d %H:%M:%S") }
    server      { Ks::SERVERS.sample }
  end
end
