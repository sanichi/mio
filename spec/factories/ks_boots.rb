FactoryBot.define do
  factory :ks_boot, class: Ks::Boot do
    happened_at { Faker::Time.backward(days: 1).utc.strftime("%Y-%m-%d %H:%M:%S") }
    server      { Ks::SERVERS.sample }
    app         { Ks::Boot::APPS.sample }
  end
end
