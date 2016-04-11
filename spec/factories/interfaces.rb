FactoryGirl.define do
  factory :interface do
    address Faker::Internet.mac_address.upcase
    name    { Faker::Lorem.words(3).join(" ") }
    device
  end
end
