FactoryBot.define do
  factory :border do
    direction { Border::DIRS.sample }
  end
end
