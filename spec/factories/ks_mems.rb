FactoryBot.define do
  factory :ks_mem, class: Ks::Mem do
    association :journal, factory: :ks_journal
    measured_at { Faker::Time.backward(days: 1).utc.strftime("%Y-%m-%d %H:%M:%S") }
    server      { Ks::SERVERS.sample }
    total       { rand(1000) + 601 }
    used        { rand(200) + 1 }
    free        { rand(201) }
    avail       { rand(201) }
    swap_used   { rand(501) }
    swap_free   { 500 - swap_used }
  end
end
