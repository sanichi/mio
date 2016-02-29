FactoryGirl.define do
  factory :parking do
    vehicle
    bay
    noted_at { Time.now }
  end
end
