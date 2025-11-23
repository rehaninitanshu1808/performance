class User < ApplicationRecord
  self.inheritance_column = :type

  validates :email, :type, presence: true

  has_many :submitted_tickets,
    class_name: Ticket.name,
    foreign_key: "customer_id"
end
