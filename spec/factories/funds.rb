FactoryBot.define do
  factory :fund do
    annual_fee          { 0.45 }
    category            { "oeic" }
    company             { "Premier Asset Management" }
    name                { "Premier Defensive Growth - Class C" }
    performance_fee     { false }
    srri                { 3 }
    srri_estimated      { true }
    sector              { "Targeted Absolute Return" }
    size                { 246 }
    stars               { ["hl_w150"] }
  end
end
