FactoryBot.define do
  factory :user do
    email { FFaker::Internet.email  }
  end

  factory :customer, parent: :user, class: Customer.name do
    email { "customer@gmail.com" }
  end

  factory :customer_support, parent: :user, class: CustomerSupport.name do
    email { "customer_support@gmail.com" }
  end
end
