FactoryBot.define do
  factory :ks_proc, class: Ks::Proc do
    association :top, factory: :ks_top
    pid     { rand(2000) + 1 }
    mem     { rand(100000) }
    command { Faker::Lorem.words(number: 50).join(" ").truncate(100, omission: "......") }
  end
end
