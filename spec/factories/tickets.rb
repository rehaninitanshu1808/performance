FactoryBot.define do
  factory :ticket do
    description { 'Test' }
    subject { 'Test Subject' }
    status { "open" }

    customer { association :customer }
    customer_support { nil }


    trait :assigned do
      customer_support { association :customer_support }
    end

    trait :closed do
      status { "closed" }
    end
  end
end
