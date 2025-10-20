FactoryBot.define do
  factory :user do
    email        { Faker::Internet.email }
    password     { Faker::Internet.password(min_length: 6, max_length: 12) }
    role         { User::ROLES.sample }
    first_name   { Faker::Name.first_name }
    last_name    { Faker::Name.last_name }
    otp_required { false }
    otp_secret   { otp_required ? Rails.application.credentials.test.otp[:secret] : nil }
    last_otp_at  { otp_required ? 1.send(%w/week day hour/.sample).ago.to_i : nil }
  end
end
