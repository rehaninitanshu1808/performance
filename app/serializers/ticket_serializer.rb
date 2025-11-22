class TicketSerializer < ActiveModel::Serializer
  attributes :id, :subject, :description, :status

  attribute :customer_support do
    object.customer_support ? UserSerializer.new(object.customer_support).as_json : nil
  end

  attribute :customer do
    UserSerializer.new(object.customer).as_json
  end
end
