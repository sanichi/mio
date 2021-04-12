FactoryBot.define do
  factory :reading, class: Wk::Reading do
    characters { Faker::Lorem.word }
    primary    { [true, false].sample }
    vocab      factory: :wk_vocab
  end
end
