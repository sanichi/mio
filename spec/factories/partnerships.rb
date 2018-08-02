FactoryBot.define do
  factory :partnership do
    wedding       { (1955..1975).to_a.sample }
    wedding_guess { [true, false].sample }
    divorce       nil
    divorce_guess false
    marriage      { [true, false].sample }

    association :husband, factory: :person, male: true, born: (1920..1930).to_a.sample, realm: 0
    association :wife, factory: :person, male: false, born: (1925..1935).to_a.sample, realm: 0
  end
end
