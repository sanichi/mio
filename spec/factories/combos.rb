FactoryBot.define do
  factory :wk_combo, class: Wk::Combo do
    ja    { Faker::Lorem.word }
    en    { Faker::Lorem.word }
    vocab factory: :wk_vocab
  end
end
