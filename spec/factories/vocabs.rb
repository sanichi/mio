FactoryBot.define do
  factory :wk_vocab, class: 'Wk::Vocab' do
    characters          { Faker::Lorem.word.truncate(Wk::Vocab::MAX_CHARACTERS) }
    level               { rand(Wk::MAX_LEVEL) + 1 }
    meaning             { Faker::Lorem.words.join(" ").truncate(Wk::Vocab::MAX_MEANING) }
    meaning_mnemonic    { Faker::Lorem.paragraph }
    notes               { [Faker::Lorem.paragraphs(number: 3), nil].sample }
    parts               { Wk::Vocab::PARTS.values.sample(3).join(',') }
    reading             { Faker::Lorem.word.truncate(Wk::Vocab::MAX_READING) }
    reading_mnemonic    { Faker::Lorem.paragraph }
    sequence(:wk_id, 1) { |n| n }
  end
end
