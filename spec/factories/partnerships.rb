FactoryBot.define do
  factory :partnership do
    wedding       { (1955..1975).to_a.sample }
    wedding_guess { [true, false].sample }
    divorce       { nil }
    divorce_guess { false }
    marriage      { [true, false].sample }
    realm         { Person::MIN_REALM.upto(Person::MAX_REALM).to_a.sample }
  end
end
