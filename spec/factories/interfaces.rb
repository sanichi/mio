FactoryGirl.define do
  factory :interface do
    name         { Faker::Lorem.words(3).join(" ") }
    mac_address  { Faker::Internet.mac_address.upcase }
    ip_address   { Faker::Internet.ip_v4_address.gsub(/\/.*\z/, "") }
    manufacturer { [nil, Faker::Company.name].sample }
    device
  end
end
