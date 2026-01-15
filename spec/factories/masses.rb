FactoryBot.define do
  factory :mass do
    date     { Date.today }
    start    { Mass::MIN_KG + rand(0.0..10.0) }
    finish   { Mass::MAX_KG - rand(0.0..10.0) }
    start_2  { Mass::MIN_KG + rand(0.0..10.0) }
    finish_2 { Mass::MAX_KG - rand(0.0..10.0) }
  end
end
