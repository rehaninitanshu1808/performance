class TicketSerializer < ActiveModel::Serializer
  attributes :id, :subject, :description, :status

  belongs_to :customer
  belongs_to :customer_support
end
