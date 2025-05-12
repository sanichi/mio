FactoryBot.define do
  factory :ks_pcpu, class: Ks::Pcpu do
    association :cpu, factory: :ks_cpu
    pid     { rand(2000) + 1 }
    pcpu    { (rand * 100.0).round(1) }
    command { Faker::Lorem.words(number: 50).join(" ").truncate(100, omission: "......") }
  end
end
