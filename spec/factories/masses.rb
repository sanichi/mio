FactoryGirl.define do
  factory :mass do
    date   { Date.today }
    start  { Mass::MIN_KG + 10.0 }
    finish { Mass::MAX_KG - 10.0 }
  end
end
