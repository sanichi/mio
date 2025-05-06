FactoryBot.define do
  factory :wk_example, class: 'Wk::Example' do
    japanese { ["彼は現在の仕事が気に入っているようだ。", "{車}が{故障}したんだ。", "{運}が{悪かった|悪い}ね。"].sample }
    english  { Faker::Lorem.sentence.truncate(Wk::Example::MAX_EXAMPLE) }
    day      { [Faker::Date.backward(days: 365), nil].sample }
  end
end
