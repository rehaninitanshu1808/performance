class Api::V1::TicketsController < ApplicationController
  def index
    ticket_ids = [1,2,3,4,8]
    tickets = Ticket.eager_load(:customer, :customer_support).where(id: ticket_ids)

    render json: tickets, each_serializer: TicketSerializer, include: ['customer_support', 'customer']
  end
end
