FactoryGirl.define do
  factory :parking do
    vehicle
    bay      { [0, Flat::BAYS.sample].sample }
    noted_at { Time.now }
  end
end
