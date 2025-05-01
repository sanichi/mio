FactoryBot.define do
  factory :ks_journal, class: Ks::Journal do
    boot       { rand(5) }
    mem        { rand(100) }
    top        { rand(100) }
    proc       { rand(1000) }
    warnings   { rand(3) }
    okay       { [true, false].sample }
    note       { Faker::Lorem.paragraphs(number: 3) }
  end
end
