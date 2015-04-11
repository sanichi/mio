FactoryGirl.define do
  factory :fund do
    annual_fee          0.9
    category            "oeic"
    company             "Premier Asset Management"
    name                "Premier Defensive Growth - Class C"
    performance_fee     false
    risk_reward_profile 3
  end
end
