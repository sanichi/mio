FactoryBot.define do
  factory :ks_cpu, class: Ks::Cpu do
    association :journal, factory: :ks_journal
    measured_at { Faker::Time.backward(days: 1).utc.strftime("%Y-%m-%d %H:%M:%S") }
    server      { Ks::SERVERS.sample }
  end
end
