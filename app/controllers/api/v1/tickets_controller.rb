class Api::V1::TicketsController < ApplicationController
  include Pagination

  def index
    tickets = Ticket.offset(offset).limit(per_page).includes(:customer, :customer_support)
    @total_count = tickets.count

    render json: {
      tickets: ActiveModelSerializers::SerializableResource.new(
        tickets,
        each_serializer: TicketSerializer,
        include: ["customer_support", "customer"]
      ),
      pagination: page_details
    }
  end


  def create
    @ticket = customer.submitted_tickets.build(ticket_params)

    if @ticket.save
       render json: @ticket, serializer: TicketSerializer, status: :created
    else
      render json: { errors: ticket.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def ticket_params
    params.require(:ticket).permit(:subject, :description, :customer_id, :customer_support_id)
  end

  def customer
    @customer = Customer.find_by!(id: ticket_params[:customer_id])
  end
end
  