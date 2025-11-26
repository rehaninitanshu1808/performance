class Ticket < ApplicationRecord
  belongs_to :customer,
    class_name: "Customer",
    foreign_key: "customer_id"

  belongs_to :customer_support,
    class_name: "CustomerSupport",
    foreign_key: "customer_support_id",
    optional: true

  validates :status, :subject, :description, :customer, presence: true
end
