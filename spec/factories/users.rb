FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { 'password' }
    balance { 0.0 }
  end
end
