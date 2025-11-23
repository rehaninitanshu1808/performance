class CustomerSupport < User
  has_many :assigned_tickets,
    class_name: Ticket.name,
    foreign_key: "customer_support_id"
end
