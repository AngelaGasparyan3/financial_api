# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'password123' }
    role { :regular }

    trait :admin do
      role { :admin }
    end
  end

  factory :account do
    user
    sequence(:number) { |n| "ACC#{n}#{SecureRandom.hex(4)}" }
    name { 'Test Account' }
    balance { 1000.0 }

    trait :empty do
      balance { 0.0 }
    end

    trait :low_balance do
      balance { 10.0 }
    end
  end

  factory :transfer do
    association :from_account, factory: :account
    association :to_account, factory: :account
    amount { 100.0 }
    status { 'completed' }

    trait :pending do
      status { 'pending' }
    end

    trait :failed do
      status { 'failed' }
    end
  end
end
